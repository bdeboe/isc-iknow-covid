Include %IKPublic

/// Not relevant for COVID19 repo, so stripped-down and hidden
/// See also https://github.com/bdeboe/isc-iknow-setanalysis
Class Demo.SetAnalysis.Utils [ Hidden ]
{

/// Attempts to create a web application forwarding to Demo.SetAnalysis.RestHandler
ClassMethod CreateRestWebApp() As %Status [ CodeMode = objectgenerator ]
{
	set tSC = $$$OK, tCreated=0, tCurrentNS = $$$LOWER($namespace)
	try {
		set:$g(pWebAppName)="" pWebAppName = "/csp/"_tCurrentNS_"/saREST/"
		set tProperties("NameSpace") = tCurrentNS
		set tProperties("DispatchClass") = "Demo.SetAnalysis.RestHandler"
		set tProperties("AutheEnabled") = $$$AutheUnauthenticated + $$$AutheCache
		//set tProperties("iKnowEnabled") = 1
		
		zn "%SYS"
		if ##class(Security.Applications).Exists(pWebAppName) {
			write !,"Web app ",pWebAppName," already exists",!
		} else {
			set tSC = ##class(Security.Applications).Create(pWebAppName, .tProperties)
			quit:$$$ISERR(tSC)
			set tCreated=1
		}
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	zn tCurrentNS
	
	if $$$ISERR(tSC) {
		write !,"WARNING: unable to create web application due to the following error:",!
		do $system.OBJ.DisplayError(tSC)
		write !,"You'll still have to create a web application '",pWebAppName,"' referring to Demo.SetAnalysis.RestHandler",!
	} elseif (tCreated) {
		write !,"Web Application '"_pWebAppName_"' created successfully",!
	}
	do %code.WriteLine("	quit $$$OK")
	quit $$$OK
}

}

