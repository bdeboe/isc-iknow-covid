Class Research.Document.metadata.authors Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Property affiliation As Research.Document.metadata.authors.affiliation(%JSONFIELDNAME = "affiliation");

Property email As %String(%JSONFIELDNAME = "email", MAXLEN = "");

Property first As %String(%JSONFIELDNAME = "first", MAXLEN = "");

Property last As %String(%JSONFIELDNAME = "last", MAXLEN = "");

Relationship metadata As Research.Document.metadata [ Cardinality = parent, Inverse = authors ];

Property middle As list Of %String(%JSONFIELDNAME = "middle", MAXLEN = "");

Property suffix As %String(%JSONFIELDNAME = "suffix", MAXLEN = "");

Storage Default
{
<Data name="authorsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>affiliation</Value>
</Value>
<Value name="3">
<Value>email</Value>
</Value>
<Value name="4">
<Value>first</Value>
</Value>
<Value name="5">
<Value>last</Value>
</Value>
<Value name="6">
<Value>middle</Value>
</Value>
<Value name="7">
<Value>suffix</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("authors")</DataLocation>
<DefaultData>authorsDefaultData</DefaultData>
<IdLocation>^Research.Document.metadataC("authors")</IdLocation>
<IndexLocation>^Research.Document25CD.authorsI</IndexLocation>
<StreamLocation>^Research.Document25CD.authorsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

