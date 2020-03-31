Class Research.Document.abstract Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship Document As Research.Document [ Cardinality = parent, Inverse = abstract ];

Relationship citespans As Research.Document.abstract.citespans(%JSONFIELDNAME = "cite_spans") [ Cardinality = children, Inverse = abstract ];

Relationship refspans As Research.Document.abstract.refspans(%JSONFIELDNAME = "ref_spans") [ Cardinality = children, Inverse = abstract ];

Property section As %String(%JSONFIELDNAME = "section", MAXLEN = "");

Property text As %String(%JSONFIELDNAME = "text", MAXLEN = "");

Storage Default
{
<Data name="abstractDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>citespans</Value>
</Value>
<Value name="3">
<Value>refspans</Value>
</Value>
<Value name="4">
<Value>section</Value>
</Value>
<Value name="5">
<Value>text</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("abstract")</DataLocation>
<DefaultData>abstractDefaultData</DefaultData>
<IdLocation>^Research.DocumentC("abstract")</IdLocation>
<IndexLocation>^Research.Document.abstractI</IndexLocation>
<StreamLocation>^Research.Document.abstractS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

