Class Research.Document.backmatter Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship Document As Research.Document [ Cardinality = parent, Inverse = backmatter ];

Relationship citespans As Research.Document.backmatter.citespans(%JSONFIELDNAME = "cite_spans") [ Cardinality = children, Inverse = backmatter ];

Relationship refspans As Research.Document.backmatter.refspans(%JSONFIELDNAME = "ref_spans") [ Cardinality = children, Inverse = backmatter ];

Property section As %String(%JSONFIELDNAME = "section", MAXLEN = "");

Property text As %String(%JSONFIELDNAME = "text", MAXLEN = "");

Storage Default
{
<Data name="backmatterDefaultData">
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
<DataLocation>{%%PARENT}("backmatter")</DataLocation>
<DefaultData>backmatterDefaultData</DefaultData>
<IdLocation>^Research.DocumentC("backmatter")</IdLocation>
<IndexLocation>^Research.Document.backmatterI</IndexLocation>
<StreamLocation>^Research.Document.backmatterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

