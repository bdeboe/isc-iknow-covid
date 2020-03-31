Class Research.Document.bodytext Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship Document As Research.Document [ Cardinality = parent, Inverse = bodytext ];

Relationship citespans As Research.Document.bodytext.citespans(%JSONFIELDNAME = "cite_spans") [ Cardinality = children, Inverse = bodytext ];

Relationship refspans As Research.Document.bodytext.refspans(%JSONFIELDNAME = "ref_spans") [ Cardinality = children, Inverse = bodytext ];

Property section As %String(%JSONFIELDNAME = "section", MAXLEN = "") [ SqlFieldName = section_name ];

Property text As %String(%JSONFIELDNAME = "text", MAXLEN = "");

Storage Default
{
<Data name="bodytextDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>refspans</Value>
</Value>
<Value name="3">
<Value>section</Value>
</Value>
<Value name="4">
<Value>text</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("bodytext")</DataLocation>
<DefaultData>bodytextDefaultData</DefaultData>
<IdLocation>^Research.DocumentC("bodytext")</IdLocation>
<IndexLocation>^Research.Document.bodytextI</IndexLocation>
<StreamLocation>^Research.Document.bodytextS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

