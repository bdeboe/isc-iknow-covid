Class Research.Document.metadata.authors.affiliation Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Property institution As %String(%JSONFIELDNAME = "institution", MAXLEN = "");

Property laboratory As %String(%JSONFIELDNAME = "laboratory", MAXLEN = "");

Property location As Research.Document.metadata.authors.affiliation.location(%JSONFIELDNAME = "location");

Storage Default
{
<Data name="affiliationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>institution</Value>
</Value>
<Value name="3">
<Value>laboratory</Value>
</Value>
<Value name="4">
<Value>location</Value>
</Value>
</Data>
<DataLocation>^Research.DocumeFB8.affiliationD</DataLocation>
<DefaultData>affiliationDefaultData</DefaultData>
<IdLocation>^Research.DocumeFB8.affiliationD</IdLocation>
<IndexLocation>^Research.DocumeFB8.affiliationI</IndexLocation>
<StreamLocation>^Research.DocumeFB8.affiliationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

