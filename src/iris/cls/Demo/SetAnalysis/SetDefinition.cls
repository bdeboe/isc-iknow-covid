/// This class represents sets saved from the SetAnalysis demo application.
Class Demo.SetAnalysis.SetDefinition Extends %Persistent
{

Property DomainId As %Integer;

Property Name As %String;

Property Entities As list Of %String(MAXLEN = "");

Property CRCs As list Of %String(MAXLEN = "");

Property Logic As %String(MAXLEN = 2000);

Property Type As %String [ Calculated, ReadOnly, SqlComputeCode = { set {*} = $s({Logic}'="":"composite", 1:"entities")}, SqlComputed ];

Property CreatedBy As %String(MAXLEN = 250) [ InitialExpression = {$username}, Required ];

Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($ZTIMESTAMP,3,1,3)}, Required ];

Index NameIdx On (DomainId, Name) [ Unique ];

Index EntitiesIdx On (DomainId, Entities(ELEMENTS)) [ Type = bitmap ];

Index CRCsIdx On (DomainId, CRCs(ELEMENTS)) [ Type = bitmap ];

/// Retrieves a <class>%iKnow.Filters.Filter</class> instance representing all the sources
/// in this set.
Method GetFilter() As %iKnow.Filters.Filter
{
	if (..Logic="") {
		set tEntities = ""
		for i = 1:1:..Entities.Count() {
			set tEntities = tEntities _ $lb(..Entities.GetAt(i))
		}
		if tEntities="" {
			set tEntityFilter = ""
		} else {
			set tEntityFilter = ##class(%iKnow.Filters.ContainsEntityFilter).%New(..DomainId, .tEntities)
		}
		if '..CRCs.Count() {
			quit tEntityFilter
		}
		
		// if we still have to filter by CRCs, create a SourceIdFilter
		set tAllCRCs = ""
		for i = 1:1:..CRCs.Count() {
			set tValue = $lfs(..CRCs.GetAt(i)," ~ ")
			set tAllCRCs = tAllCRCs_$lb(tValue)
		}
		do ##class(%iKnow.Queries.SourceAPI).GetByCrcs(.tResult, ..DomainId, tAllCRCs, 0, 0)
		set i = ""
		for { 
			set i = $o(tResult(i),1,tData)
			quit:i=""
			set tAllSources(+$lg(tData,1))=""
		}
		set tCRCFilter = ##class(%iKnow.Filters.SourceIdFilter).%New(..DomainId, .tAllSources)
		if (tEntityFilter="") {
			quit tCRCFilter
		} else {
			set tFilter = ##class(%iKnow.Filters.GroupFilter).%New(..DomainId, "OR")
			do tFilter.AddSubFilter(tEntityFilter)
			do tFilter.AddSubFilter(tCRCFilter)
			quit tFilter
		}
		
	} else {
		
		set tSC = ..ParseLogic(..DomainId, ..Logic, .tTree)
		if $$$ISERR(tSC) { $$$ThrowStatus(tSC) }
		for tNode = tTree:-1:0 {
			set tOperator = $g(tTree(tNode,"operator"),"AND")
			set tNegated = $g(tTree(tNode,"negated"), 0)
			set tFilters(tNode) = ##class(%iKnow.Filters.GroupFilter).%New(..DomainId, tOperator, tNegated)
			set tChild = ""
			for {
				set tChild = $o(tTree(tNode,"children",tChild))
				quit:tChild=""
				do tFilters(tNode).AddSubFilter(tFilters(tChild))
			}
			for tLeaf = 1:1:$g(tTree(tNode,"leaf")) {
				if $d(tTree(tNode,"leaf",tLeaf,"negated")) {
					set tLeafFilter = ##class(%iKnow.Filters.GroupFilter).%New(..DomainId, "AND", 1)
					do tLeafFilter.AddSubFilter(..NameIdxOpen(..DomainId, tTree(tNode,"leaf",tLeaf)).GetFilter())
				} else {
					set tLeafFilter = ..NameIdxOpen(..DomainId, tTree(tNode,"leaf",tLeaf)).GetFilter()
				}
				do tFilters(tNode).AddSubFilter(tLeafFilter)
			}
		}
		quit tFilters(0)
	}
}

ClassMethod NameIsValid(pName As %String) As %Status
{
	quit:$zstrip(pName,"<>W")'=pName $$$ERROR($$$GeneralError,"Set name cannot have leading or trailing whitespace")
	quit:$f(pName,"(")+$f(pName,")") $$$ERROR($$$GeneralError,"Set name cannot have parentheses")
	quit:$zstrip(pName,"*C")'=pName $$$ERROR($$$GeneralError,"Set name cannot contain control characters")
	quit:$find(" "_$$$UPPER(pName)_" "," AND ") $$$ERROR($$$GeneralError,"Set name cannot contain reserved word AND")
	quit:$find(" "_$$$UPPER(pName)_" "," OR ") $$$ERROR($$$GeneralError,"Set name cannot contain reserved word OR")
	quit:$find(" "_$$$UPPER(pName)_" "," NOT ") $$$ERROR($$$GeneralError,"Set name cannot contain reserved word NOT")
	quit $$$OK
}

Method %OnValidateObject() As %Status [ Private, ServerOnly = 1 ]
{
	quit:(..Logic'="")&&..Entities.Count() $$$ERROR($$$GeneralError,"A set cannot be both based on entities and other sets")
	quit ..ParseLogic(..DomainId, ..Logic)
}

ClassMethod ParseLogic(pDomainId As %Integer, pLogic As %String, Output pTree) As %Status [ Private ]
{
	kill pTree
	set tSC = $$$OK, pTree=0
	try {
		set pLogic = $replace($replace(pLogic,")"," ) "),"("," ( ")
		set pLogic = $zstrip($zstrip(pLogic,"=W"),"*C")
		set tAnnotated = $translate($$$UPPER(pLogic),"()",$c(0,1))
		set tAnnotated = $replace(tAnnotated," AND "," "_$c(2,2,2)_" ")
		set tAnnotated = $replace(tAnnotated," OR "," "_$c(3,3)_" ")
		set tAnnotated = $replace(tAnnotated," NOT "," "_$c(4,4,4)_" ")
		
		set tPos=0, tEndPos = $l(pLogic), tCurrent="", tNode=0, tNegateNext=0
		while $i(tPos)<=tEndPos {
			set tChar = $e(tAnnotated,tPos), tCharCode=$a(tChar)
			
			// opening parentheses: start new node
			if (tCharCode=0) {
				do AddLeaf
				set pTree($i(pTree),"parent")=tNode
				set pTree(tNode,"children",pTree)=""
				set tNode = pTree
				set:tNegateNext pTree(tNode,"negated")=1, tNegateNext=0
				continue
			}
			
			// close parentheses: end current node and go back up
			elseif (tCharCode=1) {
				do AddLeaf
				set:'$d(pTree(tNode,"operator")) pTree(tNode,"operator") = "AND"
				set tNode = $g(pTree(tNode,"parent"),-1)
				if (tNode<0) {
					set tSC = $$$ERROR($$$GeneralError, "Illegal combination of sets, check parentheses") 
					quit
				}
				continue
			}
			
			// operator: AND
			elseif (tCharCode=2) {
				do AddLeaf
				if $d(pTree(tNode,"operator"),tPrevOperator) && (tPrevOperator'="AND") {
					set tSC = $$$ERROR($$$GeneralError, "Cannot mix operators")
					quit
				}
				set pTree(tNode,"operator") = "AND"
				set tPos=tPos+3
			}
			
			// operator: OR
			elseif (tCharCode=3) {
				do AddLeaf
				if $d(pTree(tNode,"operator"),tPrevOperator) && (tPrevOperator'="OR") {
					set tSC = $$$ERROR($$$GeneralError, "Cannot mix operators")
					quit
				}
				set pTree(tNode,"operator") = "OR"
				set tPos=tPos+2
			}
			
			elseif (tCharCode=4) {
				do AddLeaf
				set tNegateNext = 1
			}
			
			// skip if uninteresting
			else { set tCurrent=tCurrent_$e(pLogic,tPos) continue }
		}
		quit:$$$ISERR(tSC)
		do AddLeaf
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
	
AddLeaf
	set tCurrent = $zstrip(tCurrent,"<>W")
	if tCurrent'="" {
		if '..NameIdxExists(pDomainId, tCurrent) {
			set tSC = $$$ERROR($$$GeneralError, "Unknown set referenced in logic: '"_tCurrent_"'")
			quit
		}
		set pTree(tNode,"leaf",$i(pTree(tNode,"leaf"))) = tCurrent
		set:tNegateNext pTree(tNode,"leaf",pTree(tNode,"leaf"),"negated") = 1
		set tCurrent = ""
	}
}

Method GetEntities() As %ListOfDataTypes
{
	set tList = ..Entities
	if (..Logic'="") {
		do ..ParseLogic(..DomainId, ..Logic, .tTree)
		for i = 0:1:tTree {
			for j = 1:1:$g(tTree(i,"leaf")) {
				set tSetName = tTree(i,"leaf",j)
				set tSet = ..NameIdxOpen(..DomainId, tSetName)
				set tEntities = tSet.GetEntities()
				for k = 1:1:tEntities.Count() {
					do tList.Insert(tEntities.GetAt(k))
				}
			}
		}
	}
	quit tList
}

Method GetCRCs() As %ListOfDataTypes
{
	set tList = ..CRCs
	if (..Logic'="") {
		do ..ParseLogic(..DomainId, ..Logic, .tTree)
		for i = 0:1:tTree {
			for j = 1:1:$g(tTree(i,"leaf")) {
				set tSetName = tTree(i,"leaf",j)
				set tSet = ..NameIdxOpen(..DomainId, tSetName)
				set tCRCs = tSet.GetCRCs()
				for k = 1:1:tCRCs.Count() {
					do tList.Insert(tCRCs.GetAt(k))
				}
			}
		}
	}
	quit tList
}

Storage Default
{
<Data name="SetDefinitionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DomainId</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Entities</Value>
</Value>
<Value name="5">
<Value>Logic</Value>
</Value>
<Value name="6">
<Value>CRCs</Value>
</Value>
<Value name="7">
<Value>CreatedBy</Value>
</Value>
<Value name="8">
<Value>CreatedAt</Value>
</Value>
</Data>
<DataLocation>^Demo.SetAnalEB18.SetDefinitionD</DataLocation>
<DefaultData>SetDefinitionDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^Demo.SetAnalEB18.SetDefinitionD</IdLocation>
<IndexLocation>^Demo.SetAnalEB18.SetDefinitionI</IndexLocation>
<StreamLocation>^Demo.SetAnalEB18.SetDefinitionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

