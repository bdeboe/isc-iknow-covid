Class COVID.Utils
{

ClassMethod CleanUp() As %Status
{
	set tRS = ##class(%SQL.Statement).%ExecDirect(,"SELECT Name FROM %Dictionary.CompiledClass WHERE Name LIKE 'Research.Document%'")
	while tRS.%Next() {
		do $classmethod(tRS.Name,"%KillExtent")
	}
	quit ##class(Research.FullDocument).%KillExtent()
}

ClassMethod Download(pFiles As %String = "biorxiv_medrxiv,comm_use_subset,noncomm_use_subset,custom_license", pUpdate = "2020-04-10", pTempDir As %String = "") As %Status
{
	set tSC = $$$OK
	try {
		set tSeparator = $s($$$isWINDOWS:"\",1:"/")
		if pTempDir="" {
			set pTempDir = $s($$$isWINDOWS:"C:\tmp\covid19\", 1:"/tmp/covid19/")
		} elseif $e(pTempDir,*)'=tSeparator {
			set pTempDir = pTempDir_tSeparator
		}
		do ##class(%File).CreateDirectoryChain(pTempDir)
		
		set tHttpRequest = ##class(%Net.HttpRequest).%New()
		set tHttpRequest.Server = "ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com"
		set tHttpRequest.Https = 1
		set tHttpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"
		
		set tFilePtr = ##class(%Stream.FileBinary).%New()
		for i = 1:1:$l(pFiles,",") {
			set tFilename = $piece(pFiles,",",i), tURL = pUpdate_"/"_tFilename_".tar.gz"
			
			w !!,"Downloading ",tURL," ..."
			set tSC = tHttpRequest.Get(tURL)
			quit:$$$ISERR(tSC)
			if tHttpRequest.HttpResponse.StatusCode'=200 {
				w !,"HTTP error code trying to fetch archive: ",tHttpRequest.HttpResponse.StatusCode
				continue
			}
			
			set tSC = tFilePtr.LinkToFile(pTempDir_tFilename_".tar.gz")
			quit:$$$ISERR(tSC)
			
			set tSC = tFilePtr.CopyFromAndSave(tHttpRequest.HttpResponse.Data)
			quit:$$$ISERR(tSC)
			
			w " (",$normalize(tFilePtr.FileBinarySize()/1024/1024,2),"MB)"
			
			w !,"Unzipping..."
			do ##class(%File).CreateDirectoryChain(pTempDir_tFilename)
			do ##class(%File).CreateDirectoryChain(pTempDir_tFilename_tSeparator_"pdf_json")
			do ##class(Utils.FileBinaryTar).ExtractFile(tFilePtr.Filename, 1, pTempDir)
			w " done"
			
			w !,"Loading into Research.FullDocument table.."
			set tSC = ..LoadDir(pTempDir_tFilename,,,1)
			quit:$$$ISERR(tSC)
			
			w !,"Cleaning up temporary files"
			do ##class(%File).Delete(pTempDir_tFilename)
		}
		quit:$$$ISERR(tSC)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod LoadAll(pBaseDir As %String = "C:\Users\bdeboe\Desktop\covid\", pSkipExistingPaperID As %Boolean = 1) As %Status
{
	set tSC = $$$OK
	try {
		set tSep = $s($$$isWINDOWS:"\",1:"/")
		set:$e(pBaseDir,*)'=tSep pBaseDir = pBaseDir_tSep
		
		do ..CleanUp()
		
		for tDir = "pmc_custom_license", "comm_use_subset", "noncomm_use_subset", "biorxiv_medrxiv" {
			set tSC = ..LoadDir(pBaseDir_tDir_tSep)
			quit:$$$ISERR(tSC)
		}
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod LoadDir(pDir As %String = "C:\Users\bdeboe\Desktop\covid\pmc_custom_license\", pStore As %String(VALUELIST=",raw,full") = "full", pMaxErrors As %Integer = 100, pSkipExistingPaperID As %Boolean = 1) As %Status
{
	set tSC = $$$OK
	try {
		set tSep = $s($$$isWINDOWS:"\",1:"/")
		set:$e(pDir,*)'=tSep pDir = pDir_tSep
		
		write !,"Loading from directory: ",pDir
		
		set tRS = ##class(%ResultSet).%New()
		set tRS.ClassName = "%File"
		set tRS.QueryName = "FileSet"
		do tRS.%Execute(pDir, "*.json",, 1)
		// ignore errors. they would simply mean the directory isn't there
		
		set tFile = ##class(%Stream.FileCharacter).%New()
		
		set (n,errors) = 0
		while tRS.%Next() { 
			if tRS.%Get("Type")="D" {
				set tSubdirs($i(tSubdirs))=tRS.%Get("Name")
				continue
			}
			
			set tRecord = ##class(Research.Document).%New()
			do tFile.LinkToFile(tRS.Name)
			
			set tPaperID = $e($piece(tFile.Filename,tSep,*),1,*-5)				
			continue:pSkipExistingPaperID&&##class(Research.FullDocument).idxPaperExists(tPaperID)

			
			set tSC = tRecord.%JSONImport(tFile)
			if $$$ISERR(tSC) {
				write !,"Error reading JSON for paper ",tPaperID,", skipping"
				set errors = errors+1
				quit:errors>=pMaxErrors
				continue
			}
			
			if (pStore = "raw") {
				
				set tRecord.Filename = $piece(tFile.Filename,tSep,*)
				set tRecord.Source = $piece(pDir,tSep,*-1)
				set tSC = tRecord.%Save()
				
			} else {
				
				set tFullDoc = ##class(Research.FullDocument).%New()
				set tFullDoc.Source = $piece(pDir,tSep,*-1)
				set tFullDoc.Filename = tFile.Filename
				set tFullDoc.PaperID = tPaperID
				set tFullDoc.Title = tRecord.metadata.title
				
				set tText = ""
				
				// some papers are badly encoded: truncate title to 25 words
				if $l(tFullDoc.Title)>250 {
					set tText = tFullDoc.Title
					set tFullDoc.Title = $piece(tFullDoc.Title," ",1,25)
					write !,"Bad title for paper ",tPaperID," - prepending to Abstract and truncating"
				}
				
				for i = 1:1:tRecord.abstract.Count() {
					set tText = tText _ $c(13,10,13,10) _ tRecord.abstract.GetAt(i).text
				}
				do tFullDoc.Abstract.Write($zstrip(tText,"<>C"))
				
				set tText=""
				for i = 1:1:tRecord.bodytext.Count() {
					set tText = tText _ $c(13,10,13,10) _ tRecord.bodytext.GetAt(i).text
				}
				do tFullDoc.BodyText.Write($zstrip(tText,"<>C"))
				
				set tSC = tFullDoc.%Save()
			}
			
			if $$$ISERR(tSC) {
				write !,"Error writing paper ",tPaperID, /*" (",$system.Status.GetErrorText(tSC),")",*/ ", skipping"
				set errors = errors+1
				quit:errors>=pMaxErrors
			} else {
				set n = n+1
			}
		}
		quit:$$$ISERR(tSC)
		write !,"Loaded ",n," documents",!
		
		// recurse into subdirs (after 2020-04-10)
		for i = 1:1:$g(tSubdirs) {
			set tSC = ..LoadDir(tSubdirs(i)_tSep,pStore,pMaxErrors,pSkipExistingPaperID)
			quit:$$$ISERR(tSC)
		}
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

}

