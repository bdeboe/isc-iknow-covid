Class COVID.Utils.ContainsCRCFilter Extends %iKnow.Filters.Filter
{

Property CRCs As %List;

Method %OnNew(pDomainId As %Integer, ByRef pCRCList As %List) As %Status [ Private, ServerOnly = 1 ]
{
	set tSC = $$$OK
	try {
		$$$CHECKDOMAINEXISTSX(pDomainId,tSC)
		set i%DomainId = pDomainId
		set i%CRCs = pCRCList
	
		set tSC = ..Initialize()
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

Method CRCsSet(pCRCList As %List) As %Status [ Internal, ServerOnly = 1 ]
{
	set i%CRCs = pCRCList
	quit ..ChangeParams()
}

///  <p>This is the primary method that needs to be implemented by an actual <class>%iKnow.Filters.Filter</class>
///  subclass to translate the abstract filter criteria the subclass addresses into a bitstring based on 
///  Source IDs. The subclass' implementation of this method should use <method>SetSourceBits</method>
///  for this purpose, setting the requested bitstrings for each offset up to <var>maxOffset</var>.</p>
Method BuildSourceFilter(maxOffset As %Integer) As %Status [ Private ]
{
	set tSC = ##class(%iKnow.Queries.SourceAPI).GetByCrcs(.tResult, ..DomainId, ..CRCs, 0, 0)
	quit:$$$ISERR(tSC) tSC
	set i = ""
	for {
		set i = $order(tResult(i),1,tData)
		quit:i=""
		$$$IKBITOFFPOS($lg(tData,1),tOff,tPos)
		set $bit(tBits(tOff),tPos)=1
	}
	set tOff=""
	for {
		set tOff = $order(tBits(tOff),1,tBits)
		quit:tOff=""
		do ..SetSourceBits(tOff,tBits)
	}
	quit $$$OK
}

///  <p>Default implementation, with the filterParams corresponding to all <method>%New</method> arguments.
///  See also <method>RestoreFilterFromString</method>.</p>
ClassMethod RestoreFilterFromStringInternal(filterParams As %String) As %iKnow.Filters.Filter [ Private ]
{
	set tDomainId = $piece(filterParams,"|",1), tList=""
	for i=2:1:$l(filterParams,"|") {
		set tList = tList _ $lb($lfs($piece(filterParams,"|",i),":"))
	}
	quit ..%New(tDomainId, tList)
}

///  <p>Subclasses should implement this method to build a string representation of the filter
///  instance. It should start with the filter class name, followed by a pipe (|) character and
///  then a string representation that can be interpreted by its <method>RestoreFilterFromStringInternal</method>
///  implementation.</p>
Method ToString() As %String
{
	set tString = $classname()_"|"_..DomainId
	for i = 1:1:$ll(..CRCs) {
		set tString = tString_"|"_$lts($lg(..CRCs,i),":")
	}
	quit tString
}

}

