Include %IKPublic

IncludeGenerator %IKPublic

/// See also https://github.com/bdeboe/isc-iknow-setanalysis
Class Demo.SetAnalysis.RestHandler Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter IKPAGESIZE As INTEGER = 200;

/// As the app only shows spread, this filter mode will do all we need with less work than
/// the classic $$$FILTERALLANDSORT
Parameter IKPFILTERMODE As INTEGER = {$$$FILTERALLANDSORT};

Parameter JSONFORMATPARAMS As STRING = "aelotwu";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>

<Route Url="/Domain/:domain/Features" Method="GET" Call="GetFeatures" />

<Route Url="/Domain/:domain/Sources" Method="GET" Call="GetSources" />
<Route Url="/Domain/:domain/Sources/:sourceID" Method="GET" Call="GetSource" />
<Route Url="/Domain/:domain/Sources/Set/:setId" Method="GET" Call="GetSourcesBySet"/>
<Route Url="/Domain/:domain/Sources/Set/:setId1/:setId2" Method="GET" Call="GetSourcesBySetOverlap"/>

<Route Url="/Domain/:domain/Sentences" Method="POST" Call="GetSentences"/>

<Route Url="/Domain/:domain/Entities" Method="POST" Call="GetEntities"/>

<Route Url="/Domain/:domain/CRCs" Method="POST" Call="GetCRCs"/>

<Route Url="/Domain/:domain/Sets/Info" Method="GET" Call="GetSetInfo"/>
<Route Url="/Domain/:domain/Sets/Save" Method="POST" Call="SaveSet"/>
<Route Url="/Domain/:domain/Sets/Delete" Method="POST" Call="DeleteSet"/>
<Route Url="/Domain/:domain/Sets/Update" Method="POST" Call="UpdateSet"/>

<Route Url="/Domain/:domain/Sets/Overlaps/:setId" Method="GET" Call="GetSetOverlap"/>

<Route Url="/Domain/:domain/Sentiment" Method="GET" Call="GetSentimental" />
<Route Url="/Domain/:domain/Sentiment" Method="POST" Call="GetSentimental" />
</Routes>
}

/// Retrieves all sources (including full text and metadata) in the domain and prints them as JSON
ClassMethod GetSources(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set tSC = ..GetSourcesInternal(pDomainId)
		quit:$$$ISERR(tSC)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

ClassMethod GetFilter(pDomainId As %Integer, pFilterSpec As %String = "") As %iKnow.Filters.Filter [ Private ]
{
	set:pFilterSpec="" pFilterSpec = %request.Content.filter
	quit:(pFilterSpec="") ""
	set tSetDef = ##class(Demo.SetAnalysis.SetDefinition).NameIdxOpen(pDomainId, pFilterSpec)
	quit:'$isobject(tSetDef) ""
	quit tSetDef.GetFilter()
}

/// Retrieves all sentences (including full text) in the domain containing <var>pEntity</var> and prints them as JSON
ClassMethod GetSentences(pDomainId As %Integer, pRequest As %String, pIncludeSentimentFlags As %Boolean = 1) As %Status
{
	set tSC = $$$OK
	try {
		set:$data(%response) %response.ContentType="application/json"
		
		if (%request.Content.type = "entity") {
			set tEntityId = ##class(%iKnow.Queries.EntityAPI).GetId(pDomainId, %request.Content.value)
			set:'tEntityId tEntityId = ##class(%iKnow.Queries.EntityAPI).GetId(pDomainId, $zcvt(%request.Content.value,"I","URL"))
			set tHighlight("ENTITY", tEntityId) = "<b class=""entity"" title=""entity '"_$zcvt(%request.Content.value,"O","HTML")_"'"">"
			set tSC = ##class(%iKnow.Queries.SentenceAPI).GetByEntities(.tSentences, pDomainId, %request.Content.value, ..GetFilter(pDomainId, %request.Content.filter), 1, ..#IKPAGESIZE)
			quit:$$$ISERR(tSC)
		} else {
			set tCRCId = ##class(%iKnow.Queries.CrcAPI).GetId(pDomainId, $piece(%request.Content.value," ~ ",1), $piece(%request.Content.value," ~ ",2), $piece(%request.Content.value," ~ ",3))
			set tHighlight("CRC", tCRCId) = "<b class=""entity"" title=""CRC '"_$zcvt(%request.Content.value,"O","HTML")_"'"">"
			set tSC = ##class(%iKnow.Queries.SentenceAPI).GetByCrcIds(.tSentences, pDomainId, tCRCId, ..GetFilter(pDomainId, %request.Content.filter), 1, ..#IKPAGESIZE)
			quit:$$$ISERR(tSC)
		}
		
		set tJSON = ##class(%ZEN.proxyObject).%New()
		set tJSON.Sentences = ##class(%ListOfObjects).%New()
		set i = ""
		for {
			set i = $order(tSentences(i), 1, tSentData)
			quit:i=""
			set tSentId = $lg(tSentData,3)
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.SourceId = $lg(tSentData,1)
			set tProxy.ExternalId = $lg(tSentData,2)
			set tProxy.SentenceId = $lg(tSentData,3)
			set tProxy.Text = ..GetHighlightedSentence(pDomainId, tProxy.SentenceId, .tHighlight, .tSC)
			quit:$$$ISERR(tSC)
			
			if pIncludeSentimentFlags && (%request.Content.type = "entity") {
				set tSC = ##class(%iKnow.Queries.SentenceAPI).GetParts(.tParts, pDomainId, tProxy.SentenceId)
				quit:$$$ISERR(tSC)
				set j = ""
				for {
					set j = $order(tParts(j),1,tPartData)
					quit:j=""
					continue:$lg(tPartData,2)'=tEntityId
					set:##class(%iKnow.Queries.EntityAPI).IsAttributed(pDomainId, $lg(tPartData,1), $$$IKATTSENPOSITIVE) tProxy.HasPositive = 1
					set:##class(%iKnow.Queries.EntityAPI).IsAttributed(pDomainId, $lg(tPartData,1), $$$IKATTSENNEGATIVE) tProxy.HasNegative = 1
				}
			}
			
			do tJSON.Sentences.Insert(tProxy)
		}
		quit:$$$ISERR(tSC)
		
		do tJSON.%ToJSON(,..#JSONFORMATPARAMS)
		
    } catch (ex) {
        set tSC=ex.AsStatus()
    }
	quit ..ErrorHandler(tSC)
}

/// Retrieves the list of sources in <var>pSetId</var> and prints them to JSON.
ClassMethod GetSourcesBySet(pDomainId As %Integer, pSetId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set tSet = ##class(SetDefinition).%OpenId(pSetId)
		
		// retrieve entities of both sets to highlight
		set tEntities = tSet.GetEntities()
		for i = 1:1:tEntities.Count() {
			set tEntity = tEntities.GetAt(i)
			continue:tEntity=""
			set tHighlight("ENTITY", tEntity) = "<b class=""entityInSet1"" title=""entity '"_$zcvt(tEntity,"O","HTML")_"' indicates set '"_tSet.Name_"'"">"
		}
		set tCRCs = tSet.GetCRCs()
		for i = 1:1:tCRCs.Count() {
			set tCRC = tCRCs.GetAt(i)
			continue:tCRC=""
			set tCRCId = ##class(%iKnow.Queries.CrcAPI).GetId(pDomainId, $piece(tCRC," ~ ",1), $piece(tCRC," ~ ",2), $piece(tCRC," ~ ",3))
			set tHighlight("CRC", tCRCId) = "<b class=""entityInSet1"" title=""CRC '"_$zcvt(tCRC,"O","HTML")_"' indicates set '"_tSet.Name_"'"">"
		}
		
		set tSC = ..GetSourcesInternal(pDomainId, tSet.GetFilter(),, .tHighlight, 1)
		quit:$$$ISERR(tSC)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Retrieves the list of sources part of both <var>pSetId1</var> and <var>pSetId2</var> and prints them to JSON.
ClassMethod GetSourcesBySetOverlap(pDomainId As %Integer, pSetId1 As %Integer, pSetId2 As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set tSet1 = ##class(SetDefinition).%OpenId(pSetId1)
		set tSet2 = ##class(SetDefinition).%OpenId(pSetId2)
		
		set tFilter = ##class(%iKnow.Filters.GroupFilter).%New(pDomainId, $$$GROUPFILTERAND)
		do tFilter.AddSubFilter(tSet1.GetFilter())
		do tFilter.AddSubFilter(tSet2.GetFilter())
		
		// retrieve entities of both sets to highlight
		set tEntities1 = tSet1.GetEntities()
		for i = 1:1:tEntities1.Count() {
			set tEntity = tEntities1.GetAt(i)
			continue:tEntity=""
			set tHighlight("ENTITY", tEntity) = "<b class=""entityInSet1"" title=""entity '"_$zcvt(tEntity,"O","HTML")_"' indicates set '"_tSet1.Name_"'"">"
		}
		set tCRCs1 = tSet1.GetCRCs()
		for i = 1:1:tCRCs1.Count() {
			set tCRC = tCRCs1.GetAt(i)
			continue:tCRC=""
			set tCRCId = ##class(%iKnow.Queries.CrcAPI).GetId(pDomainId, $piece(tCRC," ~ ",1), $piece(tCRC," ~ ",2), $piece(tCRC," ~ ",3))
			set tHighlight("CRC", tCRCId) = "<b class=""entityInSet1"" title=""CRC '"_$zcvt(tCRC,"O","HTML")_"' indicates set '"_tSet1.Name_"'"">"
		}
		
		set tEntities2 = tSet2.GetEntities()
		for i = 1:1:tEntities2.Count() {
			set tEntity = tEntities2.GetAt(i)
			continue:tEntity=""
			set tHighlight("ENTITY", tEntity) = "<b class=""entityInSet2"" title=""entity '"_$zcvt(tEntity,"O","HTML")_"' indicates set '"_tSet2.Name_"'"">"
		}
		set tCRCs2 = tSet2.GetCRCs()
		for i = 1:1:tCRCs2.Count() {
			set tCRC = tCRCs2.GetAt(i)
			continue:tCRC=""
			set tCRCId = ##class(%iKnow.Queries.CrcAPI).GetId(pDomainId, $piece(tCRC," ~ ",1), $piece(tCRC," ~ ",2), $piece(tCRC," ~ ",3))
			set tHighlight("CRC", tCRCId) = "<b class=""entityInSet2"" title=""CRC '"_$zcvt(tCRC,"O","HTML")_"' indicates set '"_tSet2.Name_"'"">"
		}
		
		set tSC = ..GetSourcesInternal(pDomainId, tFilter,, .tHighlight, 1)
		quit:$$$ISERR(tSC)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Utility method to print a list of sources to JSON
ClassMethod GetSourcesInternal(pDomainId As %Integer, pFilter As %iKnow.Filters.Filter = "", pFilterByEntity As %String = "", ByRef pHighlight, pGetMetadata As %Boolean = 1) As %Status [ Private ]
{
	set tSC = $$$OK
	try {
		set:$data(%response) %response.ContentType="application/json"
		
		// fetch SetDefinition objects for set membership metadata
		set tSets = 0
		if (pGetMetadata) {
			set tSQL = "SELECT ID FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = "_pDomainId
			set tResult = ##class(%SQL.Statement).%ExecDirect(,tSQL)
			while tResult.%Next() {
				set tSets($i(tSets)) = ##class(SetDefinition).%OpenId(tResult.%Get("ID"))
			}
			kill tResult
		}
		
		set tJSON = ##class(%ZEN.proxyObject).%New()
		set tJSON.Sources = ##class(%ListOfObjects).%New()
		set tSC = ##class(%iKnow.Queries.SourceAPI).GetByDomain(.tResult, pDomainId, 1, ..#IKPAGESIZE,  pFilter)
		quit:$$$ISERR(tSC)
		set i = ""
		for {
			set i = $order(tResult(i), 1, tData)
			quit:i=""
			
			set tSrcId = $lg(tData,1)
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.SourceId = tSrcId
			
			// add fulltext
			set tProxy.FullText = ..GetHighlightedSource(pDomainId, tSrcId, pFilterByEntity,, .pHighlight, .tSC)
			quit:$$$ISERR(tSC)
			
			// add metadata
			if pGetMetadata {
				set tSC = ##class(%iKnow.Queries.MetadataAPI).GetValuesById(.tMetadata, pDomainId, tSrcId)
				quit:$$$ISERR(tSC)
				set j = ""
				for {
					set j = $order(tMetadata(j),1,tMD)
					quit:j=""
					set tFieldName = $li(tMD,2)
					continue:tFieldName="DateIndexed"
					set $property(tProxy,tFieldName) = $lg(tMD,3)
				}
				
				// get sets for source
				set tProxy.Sets = ##class(%ListOfObjects).%New() 
				for j = 1:1:tSets {
					if $isobject(tSets(j).GetFilter()) && tSets(j).GetFilter().IsFiltered(tSrcId) {
						do tProxy.Sets.Insert(tSets(j))
					}
				}
			}
			
			do tJSON.Sources.Insert(tProxy)
		}
		
		do tJSON.%ToJSON(,..#JSONFORMATPARAMS)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

ClassMethod GetSource(pDomainId As %Integer, pSourceId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set:$data(%response) %response.ContentType="application/json"
		
		set tJSON = ##class(%ZEN.proxyObject).%New()
		set tJSON.SourceId = pSourceId
		set tJSON.Text = ..GetHighlightedSource(pDomainId, pSourceId,, 9999,,.tSC)
		quit:$$$ISERR(tSC)
		
		set tJSON.Metadata = ##class(%ZEN.proxyObject).%New()
		set tSC = ##class(%iKnow.Queries.MetadataAPI).GetValuesById(.tMetadata, pDomainId, pSourceId)
		quit:$$$ISERR(tSC)
		set j = ""
		for {
			set j = $order(tMetadata(j),1,tMD)
			quit:j=""
			set tFieldName = $li(tMD,2)
			continue:tFieldName="DateIndexed"
			set $property(tJSON.Metadata,tFieldName) = $lg(tMD,3)
		}
		
		// get sets for source
		set tSQL = "SELECT ID FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = "_pDomainId
		set tResult = ##class(%SQL.Statement).%ExecDirect(,tSQL)
		while tResult.%Next() {
			set tSets($i(tSets)) = ##class(SetDefinition).%OpenId(tResult.%Get("ID"))
		}
		kill tResult
		set tJSON.Sets = ##class(%ListOfObjects).%New() 
		for j = 1:1:tSets {
			if tSets(j).GetFilter().IsFiltered(pSourceId) {
				do tJSON.Sets.Insert(tSets(j))
			}
		}
		
		do tJSON.%ToJSON(,..#JSONFORMATPARAMS)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Retrieves a highlighted summary of the text in source <var>pSourceId</var>, optionally filtered to the
/// sentences containing <var>pFilterByEntity</var>. At most <var>pMaxSentences</var> will be returned.
/// Any markup in <var>pHighlight</var> is appended with default highlighting of negations
ClassMethod GetHighlightedSource(pDomainId As %Integer, pSourceId As %Integer, pFilterByEntity As %String = "", pMaxSentences As %Integer = 5, ByRef pHighlight, Output pSC As %Status = {$$$OK}) As %String
{
	set pSC = $$$OK, tString = ""
	try {
		
		// first select by entities
		if (pFilterByEntity'="") {
			set pHighlight("ENTITY", pFilterByEntity) = "<b class=""entity"" title=""entity '"_$zcvt(pFilterByEntity,"O","HTML")_"'"">"
			set pSC = ##class(%iKnow.Queries.SentenceAPI).GetByEntities(.tSentences, pDomainId, pFilterByEntity, $lb(pSourceId), 0)
			quit:$$$ISERR(pSC)
		} elseif $d(pHighlight("ENTITY")) {
			set tEntity = "", tEntityList=""
			for {
				set tEntity = $order(pHighlight("ENTITY",tEntity))
				quit:tEntity=""
				set tEntityList = tEntityList _ $lb(tEntity)
			}
			set pSC = ##class(%iKnow.Queries.SentenceAPI).GetByEntities(.tSentences, pDomainId, tEntityList, $lb(pSourceId), 0)
			quit:$$$ISERR(pSC)
		}
		set i = "", tSentIDs = ""
		for {
			set i = $order(tSentences(i),1,tSentData)
			quit:i=""
			set tSentIDs = tSentIDs _ $li(tSentData,3,3)
		}
		
		// now fetch the sentences of this source...
		// first selected by whether they are in tSentIDs, then based on summary relevance
		// and back in natural order
		set tSQL = "SELECT SentenceId, SummaryRelevance FROM %iKnow_Objects.Sentence WHERE DomainId = ? AND SourceId = ?"
		set tSQL = "SELECT TOP ? * FROM ("_tSQL_") ORDER BY CASE WHEN (SentenceId %INLIST ?) THEN 1 ELSE 0 END DESC, SummaryRelevance DESC"
		set tSQL = "SELECT * FROM ("_tSQL_") ORDER BY SentenceId ASC"
		set tStatement = ##class(%SQL.Statement).%New()
		set pSC = tStatement.%Prepare(tSQL)
		quit:$$$ISERR(pSC)
		set tResult = tStatement.%Execute(pMaxSentences, pDomainId, pSourceId, tSentIDs)
		
		
		set tSource = ##class(%iKnow.Objects.Source).PKINDEXOpen(pDomainId, pSourceId)
		set tPrevSentId = tSource.FirstSentenceId-1, tSentId=""
		while tResult.%Next() {
			set tSentId = tResult.%Get("SentenceId")
			
			set tString = tString _ $s((tPrevSentId'=(tSentId-1)):" ... ", 1:" ")
			set tPrevSentId = tSentId
			
			set tString = tString _ ..GetHighlightedSentence(pDomainId, tSentId, .pHighlight, .pSC)
			quit:$$$ISERR(pSC)
		}
		if tSentId'=(tSource.FirstSentenceId+tSource.SentenceCount-1) {
			set tString = tString _ " ..."
		}
		
	} catch (ex) {
		set pSC = ex.AsStatus()
	}
	quit tString
}

ClassMethod GetHighlightedSentence(pDomainId As %Integer, pSentenceId As %Integer, ByRef pHighlight, Output pSC As %Status) As %String
{
	set pSC = $$$OK, tSentence = ""
	try {
		// default highlighting
		set tHighlight("ATTRIBUTE", $$$IKATTSENPOSITIVE) = "<span class=""sent-pos"">"
		set tHighlight("ATTRIBUTE", $$$IKATTSENNEGATIVE) = "<font class=""sent-neg"">"
		set tHighlight("ATTRIBUTE", $$$IKATTNEGATION) = "<u class=""negation"">"
		
		// append/override with explicit highlighting requirements
		merge tHighlight = pHighlight
		
		set tSentence = ##class(%iKnow.Queries.SentenceAPI).GetHighlighted(pDomainId, pSentenceId, .tHighlight,,, .pSC)
		
	} catch (ex) {
		set pSC = ex.AsStatus()
	}
	quit tSentence
}

/// Retrieves the top entities similar to <var>pString</var> and prints them to JSON
ClassMethod GetEntities(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		if $isobject(%request.Content.blacklists) {
			set tBlacklists = ""
			for i = 1:1:%request.Content.blacklists.Count() {
				set tBlacklists = tBlacklists_$lb(%request.Content.blacklists.GetAt(i))
			}
		} else {
			set tBlacklists = ""
		}
		
		if (%request.Content.entity = "") {
			set tSC = ##class(%iKnow.Queries.EntityAPI).GetTop(.tResult, pDomainId, 1, ..#IKPAGESIZE, ..GetFilter(pDomainId), ..#IKPFILTERMODE,,,, tBlacklists)
			quit:$$$ISERR(tSC)
		} else {
			set tSC = ##class(%iKnow.Queries.EntityAPI).GetSimilar(.tResult, pDomainId, %request.Content.entity, 1, ..#IKPAGESIZE, ..GetFilter(pDomainId), ..#IKPFILTERMODE,, tBlacklists)
			quit:$$$ISERR(tSC)
		}
		
		set:$data(%response) %response.ContentType="application/json"
		set tJSON = ##class(%ZEN.proxyObject).%New()
		set tJSON.Seed = %request.Content.entity
		
		set tSC = ..EntityResultToJSON(.tResult, .tEntities)
		quit:$$$ISERR(tSC)
		
		set tJSON.Entities = tEntities
		do tJSON.%ToJSON(,..#JSONFORMATPARAMS)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Utility method for converting an array of entities to JSON
ClassMethod EntityResultToJSON(ByRef pResult, Output pJSONArray) As %Status [ Private ]
{
	set tSC = $$$OK
	try {
		set i = "", pJSONArray = ##class(%ListOfObjects).%New()
		for {
			set i = $order(pResult(i), 1, tData)
			quit:i=""
			
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.EntityValue = $lg(tData,2)
			set tProxy.Frequency = $lg(tData,3)
			set tProxy.Spread = $lg(tData,4)
			do pJSONArray.Insert(tProxy)
		}
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod GetCRCs(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set tSC = ##class(%iKnow.Queries.CrcAPI).GetByEntities(.tResult, pDomainId, %request.Content.entity, 1, ..#IKPAGESIZE, ..GetFilter(pDomainId), ..#IKPFILTERMODE)
		quit:$$$ISERR(tSC)
		
		set:$data(%response) %response.ContentType="application/json"
		set tJSON = ##class(%ZEN.proxyObject).%New()
		set tJSON.Seed = %request.Content.entity
		
		set tSC = ..CRCResultToJSON(.tResult, .tCRCs)
		quit:$$$ISERR(tSC)
		
		set tJSON.CRCs = tCRCs
		do tJSON.%ToJSON(,..#JSONFORMATPARAMS)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Utility method for converting an array of entities to JSON
ClassMethod CRCResultToJSON(ByRef pResult, Output pJSONArray) As %Status [ Private ]
{
	set tSC = $$$OK
	try {
		set i = "", pJSONArray = ##class(%ListOfObjects).%New()
		for {
			set i = $order(pResult(i), 1, tData)
			quit:i=""
			
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.Value = $lts($li(tData,2,4)," ~ ")
			set tProxy.Frequency = $lg(tData,5)
			set tProxy.Spread = $lg(tData,6)
			do pJSONArray.Insert(tProxy)
		}
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Retrieves information about all sets stored for domain <var>pDomain</var>
/// Writes the following JSON output:
/// <blockquote><pre>{
/// 	Sets: [ 
/// 				{
/// 					SetId: 123,
/// 					Name: 'abc',
/// 					Entities: [ 'xyz', 'def', ... ]
/// 				},... ],
/// 	TotalInSets: x,
/// 	TotalNotInSets: x,
/// 	TotalSources: x
/// }</pre></blockquote>
ClassMethod GetSetInfo(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set:$data(%response) %response.ContentType="application/json"
		set tJSON = ##class(%ZEN.proxyObject).%New()
		
		set tSQL = "SELECT ID FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = "_pDomainId //_" AND CreatedBy = '"_$username_"'"
		set tResult = ##class(%SQL.Statement).%ExecDirect(,tSQL)
		set tJSON.Sets = ##class(%ListOfObjects).%New()
		while tResult.%Next() {
			set tSetDef = ##class(SetDefinition).%OpenId(tResult.%Get("ID"))
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.SetId = tResult.%Get("ID")
			set tProxy.Name = tSetDef.Name
			set tProxy.Entities = tSetDef.Entities
			set tProxy.CRCs = tSetDef.CRCs
			set tProxy.Logic = tSetDef.Logic
			set tProxy.Sources = $s($isobject(tSetDef.GetFilter()):tSetDef.GetFilter().FilteredSourceCount, 1:0)
			do tJSON.Sets.Insert(tProxy)
		}
		
		// now get the counts
		set tJSON.TotalSources = ##class(%iKnow.Queries.SourceAPI).GetCountByDomain(pDomainId)
		set tJSON.TotalNotInSets = ..GetNotInSetFilter(pDomainId, .tSC).FilteredSourceCount
		quit:$$$ISERR(tSC)
		set tJSON.TotalInSets = tJSON.TotalSources - tJSON.TotalNotInSets
		
		// write JSON
		do tJSON.%ToJSON(,..#JSONFORMATPARAMS)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Saves the posted set information to a <class>SetDefintion</class>, appending the supplied list of
/// entities to any that might already exist for the set specified in the request.
/// Accepts the following JSON (as HTTP POST content):
/// <blockquote><pre>{
/// 		SetId: 123,
/// 		Name: 'name',
/// 		Entities: [ 'ent1', 'ent2' ],
/// 			Logic: 'abc AND def'
/// }</pre></blockquote>
ClassMethod SaveSet(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		// retrieve or instantiate set
		set:%request.Content.SetId tSetDef = ##class(SetDefinition).%OpenId(%request.Content.SetId)
		set:$g(tSetDef)="" tSetDef = ##class(SetDefinition).NameIdxOpen(pDomainId, %request.Content.Name)
		if tSetDef="" {
			set tSetDef = ##class(SetDefinition).%New()
			set tSetDef.Name = %request.Content.Name
			set tSetDef.DomainId = pDomainId
		}
		
		// check which entities are already in there and append
		for i = 1:1:tSetDef.Entities.Count() {
			set tEntity = tSetDef.Entities.GetAt(i)
			set tCurrentEntities(tEntity)=""
		}
		if $isobject(%request.Content.Entities) {
			for i = 1:1:%request.Content.Entities.Count() {
				set tEntity = %request.Content.Entities.GetAt(i)
				do:'$d(tCurrentEntities(tEntity)) tSetDef.Entities.Insert(tEntity)
			}
		}
		
		// same for CRCs
		for i = 1:1:tSetDef.CRCs.Count() {
			set tCRC = tSetDef.CRCs.GetAt(i)
			set tCurrentCRCs(tCRC)=""
		}
		if $isobject(%request.Content.CRCs) {
			for i = 1:1:%request.Content.CRCs.Count() {
				set tCRC = %request.Content.CRCs.GetAt(i)
				do:'$d(tCurrentCRCs(tCRC)) tSetDef.CRCs.Insert(tCRC)
			}
		}
		
		// update logic
		set tSetDef.Logic = %request.Content.Logic
		
		set tSC = tSetDef.%Save()
		quit:$$$ISERR(tSC)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Removes a single entity from a set.
/// Accepts the following JSON (as HTTP POST content):
/// <blockquote><pre>{
/// 		SetId: 123,
/// 		Name: 'name',
/// 		RemoveEntity: 'ent1'
/// }</pre></blockquote>
ClassMethod UpdateSet(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		// retrieve set
		set:%request.Content.SetId tSetDef = ##class(SetDefinition).%OpenId(%request.Content.SetId)
		set:$g(tSetDef)="" tSetDef = ##class(SetDefinition).NameIdxOpen(pDomainId, %request.Content.Name)
		quit:tSetDef=""
		if (%request.Content.Type="entity") {
			for i = 1:1:tSetDef.Entities.Count() {
				if (%request.Content.Value=tSetDef.Entities.GetAt(i)) {
					do tSetDef.Entities.RemoveAt(i)
					quit
				}
			}
		} else {
			for i = 1:1:tSetDef.CRCs.Count() {
				if (%request.Content.Value=tSetDef.CRCs.GetAt(i)) {
					do tSetDef.CRCs.RemoveAt(i)
					quit
				}
			}
		}
		
		set tSC = tSetDef.%Save()
		quit:$$$ISERR(tSC)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Deletes a <class>SetDefinition</class> instance from the table.
/// Accepts the following JSON (as HTTP POST content):
/// <blockquote><pre>{
/// 		SetId: 123
/// }</pre></blockquote>
ClassMethod DeleteSet(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set tSC = ##class(SetDefinition).%DeleteId(%request.Content.SetId)
		quit:$$$ISERR(tSC)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Retrieves the overlap information for <class>SetDefintion</class> <var>pSetId</var>, listing
/// how many sources it has in common with all other sets.
/// Writes the following JSON:
/// <blockquote><pre>{
/// 	SetId: 123,
/// 	Name: 'abc',
/// 	Overlaps: [
/// 				{
/// 					SetId: 456,
/// 					Name: 'def',
/// 					Count: 789
/// 				},... ]
/// }</pre></blockquote>
ClassMethod GetSetOverlap(pDomainId As %Integer, pSetId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set:$data(%response) %response.ContentType="application/json"
		
		set tSetDef = ##class(SetDefinition).%OpenId(pSetId)
		set tJSON = ##class(%ZEN.proxyObject).%New()
		set tJSON.SetId = pSetId
		set tJSON.Name = tSetDef.Name
		
		set tSQL = "SELECT ID FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = "_pDomainId //_" AND ID != "_pSetId
		set tResult = ##class(%SQL.Statement).%ExecDirect(,tSQL)
		set tJSON.Overlaps = ##class(%ListOfObjects).%New()
		while tResult.%Next() {
			set tOtherSetDef = ##class(SetDefinition).%OpenId(tResult.%Get("ID"))
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.SetId = tResult.%Get("ID")
			set tProxy.Name = tOtherSetDef.Name
			
			set tFilter = ##class(%iKnow.Filters.GroupFilter).%New(pDomainId,$$$GROUPFILTERAND)
			do tFilter.AddSubFilter(tSetDef.GetFilter())
			do tFilter.AddSubFilter(tOtherSetDef.GetFilter())
			set tProxy.Count = tFilter.FilteredSourceCount
			
			do tJSON.Overlaps.Insert(tProxy)
		}
		
		// write JSON
		do tJSON.%ToJSON(, ..#JSONFORMATPARAMS)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

/// Utility method to retrieve a <class>%iKnow.Filters.Filter</class> object representing all sources
/// not part of any set.
ClassMethod GetNotInSetFilter(pDomainId As %Integer, Output pSC As %Status) As %iKnow.Filters.Filter [ Internal ]
{
	set pSC = $$$OK, tFilter=""
	try {
		set tAllEntities=""
		set tResult = ##class(%SQL.Statement).%ExecDirect(,"SELECT $listtostring(Entities) FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = "_pDomainId)
		while tResult.%Next() {
			set tEntities = tResult.%GetData(1), tCount = $l(tEntities,",")
			for i = 1:1:tCount {
				set tEntity = $p(tEntities,",",i)
				continue:tEntity=""
				set tAllEntities = tAllEntities _ $lb(tEntity)
			}
		}
		if '$d(tAllEntities) {
			set tFilter = ##class(%iKnow.Filters.SourceIdFilter).%New(pDomainId, 0)
		} else {
			set tFilter = ##class(%iKnow.Filters.GroupFilter).%New(pDomainId,$$$GROUPFILTERAND,1) // =NOT
			do tFilter.AddSubFilter(##class(%iKnow.Filters.ContainsEntityFilter).%New(pDomainId, .tAllEntities))
		}
	} catch (ex) {
		set pSC = ex.AsStatus()
	}
	quit tFilter
}

/// Simple error handler, converting a <class>%Status</class> object to a JSON representation.
ClassMethod ErrorHandler(Stat As %Status) As %Status [ Private ]
{
	if $$$ISERR(Stat) {
		set errorcode=$piece(##class(%SYSTEM.Status).GetErrorCodes(Stat),",")
		set errormessage=##class(%SYSTEM.Status).GetOneStatusText(Stat)
		set errobj=##class(%ZEN.proxyObject).%New()
		set errobj.ErrorNum=errorcode
		set errobj.ErrorMessage=errormessage
		Set %response.ContentType="application/json"
		Do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(errobj)
		set errobj=""
	}
	quit $$$OK
}

ClassMethod GetSentimental(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		if $isobject(%request.Content.blacklists) {
			set tBlacklists = ""
			for i = 1:1:%request.Content.blacklists.Count() {
				set tBlacklists = tBlacklists_$lb(%request.Content.blacklists.GetAt(i))
			}
		} else {
			set tBlacklists = ""
		}
		
		set:$data(%response) %response.ContentType="application/json"
		
		set tJSON = ##class(%ZEN.proxyObject).%New()
		
		set tDomain = ##class(%iKnow.Domain).%OpenId(pDomainId)
		if '$isobject(tDomain) { set tSC = $$$ERROR($$$IKNoDomainWithId, pDomainId) }
		set tPackageName = tDomain.GetParameter($$$IKPPACKAGE)
		if (tPackageName="") { write "{ ""Entities"": [] }" quit }
		set tPartTable = $tr(tPackageName,".","_")_".Part"

		set tSQL = "SELECT * FROM "_
					"(SELECT Entity->EntUniId EntUniId, Entity->EntityValue EntityValue, SUM(Positive) TotalPositive, SUM(Negative) TotalNegative, Entity->CorpusFrequency TotalFrequency FROM "_
					"((SELECT Entity, 1 Positive, 0 Negative FROM "_tPartTable_" WHERE FOR SOME %ELEMENT(Attributes) ((%KEY = 'ATP:5') OR (%KEY = 'ATS:5')) AND EntTypeId = 0) "_
					"UNION ALL "_
					"(SELECT Entity, 0 Positive, 1 Negative FROM "_tPartTable_" WHERE FOR SOME %ELEMENT(Attributes) ((%KEY = 'ATP:6') OR (%KEY = 'ATS:6')) AND EntTypeId = 0)) u "_
					"GROUP BY Entity) "_
					"ORDER BY (TotalPositive+TotalNegative) DESC"
					
		set tResult = ##class(%SQL.Statement).%ExecDirect(,tSQL)
		set tJSON.Entities = ##class(%ListOfObjects).%New()
		while tResult.%Next() {
			
			if (tBlacklists'="") {
				set tIsBlacklisted = 0, ptr=0, tEntUniId = tResult.%Get("EntUniId")
				while $listnext(tBlacklists,ptr,tBlacklistID) {
					set tIsBlacklisted = ##class(%iKnow.Utils.MaintenanceAPI).BlacklistContainsElement(pDomainId,tBlacklistID,tEntUniId)
					quit:tIsBlacklisted
				}
				continue:tIsBlacklisted
			}
			
			set tEntity = ##class(%ZEN.proxyObject).%New()
			set tEntity.EntityValue = tResult.%Get("EntityValue")
			set tEntity.TotalPositive = tResult.%Get("TotalPositive")
			set tEntity.TotalNegative = tResult.%Get("TotalNegative")
			set tEntity.TotalFrequency = tResult.%Get("TotalFrequency")
			do tJSON.Entities.Insert(tEntity)
		}
		
		// write JSON
		do tJSON.%ToJSON(, ..#JSONFORMATPARAMS)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

ClassMethod GetFeatures(pDomainId As %Integer) As %Status
{
	set tSC = $$$OK
	try {
		set:$data(%response) %response.ContentType="application/json"
		
		set tJSON = ##class(%ZEN.proxyObject).%New()
		
		set tDomain = ##class(%iKnow.Domain).%OpenId(pDomainId)
		if '$isobject(tDomain) { set tSC = $$$ERROR($$$IKNoDomainWithId, pDomainId) quit }
		set tJSON.Name = tDomain.Name
		set tPackageName = tDomain.GetParameter($$$IKPPACKAGE)
		set tJSON.HasTables = (tPackageName'="")
		
		if tJSON.HasTables {
			set tSQL = "SELECT TOP 1 %ID FROM "_$tr(tPackageName,".","_")_".PathAttribute WHERE AttributeTypeId IN (5,6) UNION SELECT TOP 1 %ID FROM "_$tr(tPackageName,".","_")_".SentenceAttribute WHERE AttributeTypeId IN (5,6)"
			set tResult = ##class(%SQL.Statement).%ExecDirect(,tSQL)
			set tJSON.HasSentiment = (tResult.%Next() && tResult.%GetData(1))
		} else {
			set tJSON.HasSentiment = 0
		}
		
		set tJSON.MinSearchLength = tDomain.GetParameter($$$IKPMINTOPCONCEPTLENGTH)
		
		kill tResult
		set tJSON.Blacklists = ##class(%ListOfObjects).%New()
		set tSC = ##class(%iKnow.Utils.MaintenanceAPI).GetBlackLists(.tResult, pDomainId, 1)
		quit:$$$ISERR(tSC)
		set i = ""
		for {
			set i = $order(tResult(i),1,tData)
			quit:i=""
			set tProxy = ##class(%ZEN.proxyObject).%New()
			set tProxy.ID = $lg(tData,1)
			set tProxy.Name = $lg(tData,2)
			do tJSON.Blacklists.Insert(tProxy)
		}
		
		// write JSON
		do tJSON.%ToJSON(, ..#JSONFORMATPARAMS)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
	set tSC = $$$OK
	try {
        // read request object 
		if (pMethod'="POST") || (%request.Content="") {
			set %request.Content = ##class(%ZEN.proxyObject).%New()
		} elseif '$isobject(%request.Content) {
			set tSC = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(%request.Content,,.tRequestObject)
			quit:$$$ISERR(tSC)
			set %request.Content = tRequestObject
		} elseif %request.Content.AtEnd {
			set %request.Content = ##class(%ZEN.proxyObject).%New()
		} else {
			set tJSONString = ""
			while '%request.Content.AtEnd {
				set tJSONString = tJSONString_$zcvt(%request.Content.ReadLine(),"I","UTF8")
			}
			set tSC = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(tJSONString,,.tRequestObject)
			quit:$$$ISERR(tSC)
			set %request.Content = tRequestObject
		}
        
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit ..ErrorHandler(tSC)
}

}

