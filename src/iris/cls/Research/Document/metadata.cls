Class Research.Document.metadata Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship authors As Research.Document.metadata.authors(%JSONFIELDNAME = "authors") [ Cardinality = children, Inverse = metadata ];

Property title As %String(%JSONFIELDNAME = "title", MAXLEN = "");

Storage Default
{
<Data name="metadataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>title</Value>
</Value>
</Data>
<DataLocation>^Research.Document.metadataD</DataLocation>
<DefaultData>metadataDefaultData</DefaultData>
<IdLocation>^Research.Document.metadataD</IdLocation>
<IndexLocation>^Research.Document.metadataI</IndexLocation>
<StreamLocation>^Research.Document.metadataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

