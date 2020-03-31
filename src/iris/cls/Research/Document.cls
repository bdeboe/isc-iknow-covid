Class Research.Document Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Property Source As %String(MAXLEN = 200);

Property Filename As %String(MAXLEN = 1000);

Relationship abstract As Research.Document.abstract(%JSONFIELDNAME = "abstract") [ Cardinality = children, Inverse = Document ];

Relationship backmatter As Research.Document.backmatter(%JSONFIELDNAME = "back_matter") [ Cardinality = children, Inverse = Document ];

Property bibentries As Research.Document.bibentries(%JSONFIELDNAME = "bib_entries");

Relationship bodytext As Research.Document.bodytext(%JSONFIELDNAME = "body_text") [ Cardinality = children, Inverse = Document ];

Property metadata As Research.Document.metadata(%JSONFIELDNAME = "metadata");

Property paperid As %String(%JSONFIELDNAME = "paper_id", MAXLEN = "");

Property refentries As Research.Document.refentries(%JSONFIELDNAME = "ref_entries");

Storage Default
{
<Data name="DocumentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>bibentries</Value>
</Value>
<Value name="3">
<Value>metadata</Value>
</Value>
<Value name="4">
<Value>paperid</Value>
</Value>
<Value name="5">
<Value>refentries</Value>
</Value>
<Value name="6">
<Value>Source</Value>
</Value>
<Value name="7">
<Value>Filename</Value>
</Value>
</Data>
<DataLocation>^Research.DocumentD</DataLocation>
<DefaultData>DocumentDefaultData</DefaultData>
<IdLocation>^Research.DocumentD</IdLocation>
<IndexLocation>^Research.DocumentI</IndexLocation>
<StreamLocation>^Research.DocumentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

