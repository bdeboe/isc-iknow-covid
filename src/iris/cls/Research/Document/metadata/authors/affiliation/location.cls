Class Research.Document.metadata.authors.affiliation.location Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Property country As %String(%JSONFIELDNAME = "country", MAXLEN = "");

Property region As %String(%JSONFIELDNAME = "region", MAXLEN = "");

Property settlement As %String(%JSONFIELDNAME = "settlement", MAXLEN = "");

Storage Default
{
<Data name="locationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>country</Value>
</Value>
<Value name="3">
<Value>region</Value>
</Value>
<Value name="4">
<Value>settlement</Value>
</Value>
</Data>
<DataLocation>^Research.Document26D8.locationD</DataLocation>
<DefaultData>locationDefaultData</DefaultData>
<IdLocation>^Research.Document26D8.locationD</IdLocation>
<IndexLocation>^Research.Document26D8.locationI</IndexLocation>
<StreamLocation>^Research.Document26D8.locationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

