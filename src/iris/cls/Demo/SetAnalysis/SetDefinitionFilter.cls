Class Demo.SetAnalysis.SetDefinitionFilter Extends %iKnow.Filters.Filter [ Language = objectscript ]
{

Property SetName As %String;

Method %OnNew(pDomainId As %Integer, pSetName As %String) As %Status [ Internal, ServerOnly = 1 ]
{
	set i%DomainId = pDomainId
	set i%SetName = pSetName
	quit ..Initialize()
}

ClassMethod RestoreFilterFromStringInternal(filterSpec As %String) As %iKnow.Filters.Filter
{
	set domain = $piece(filterSpec, "|", 1)
	set name = $piece(filterSpec, "|", 2,*)
	quit ..%New(domain, name)
}

Method ToString() As %String
{
	quit ..%ClassName(1)_"|"_..DomainId_"|"_..SetName
}

///  <p>This is the primary method that needs to be implemented by an actual <class>%iKnow.Filters.Filter</class>
///  subclass to translate the abstract filter criteria the subclass addresses into a bitstring based on 
///  Source IDs. The subclass' implementation of this method should use <method>SetSourceBits</method>
///  for this purpose, setting the requested bitstrings for each offset up to <var>maxOffset</var>.</p>
Method BuildSourceFilter(maxOffset As %Integer) As %Status [ Private ]
{
	set tSetDef = ##class(SetDefinition).NameIdxOpen(..DomainId, ..SetName,, .tSC)
	quit:$$$ISERR(tSC) tSC
	#dim tFilter as %iKnow.Filters.Filter
	set tFilter = tSetDef.GetFilter()
	set i = ""
	for {
		set i = tFilter.GetNextSourceFilterOffset(i,.bits)
		quit:i=""
		do ..SetSourceBits(i,bits)
	}
	quit $$$OK
}

}

