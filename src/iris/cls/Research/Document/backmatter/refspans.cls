Class Research.Document.backmatter.refspans Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship backmatter As Research.Document.backmatter [ Cardinality = parent, Inverse = refspans ];

Property end As %Numeric(%JSONFIELDNAME = "end", SCALE = 0);

Property refid As %String(%JSONFIELDNAME = "ref_id", MAXLEN = "");

Property start As %Numeric(%JSONFIELDNAME = "start", SCALE = 0);

Property text As %String(%JSONFIELDNAME = "text", MAXLEN = "");

Storage Default
{
<Data name="refspansDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>end</Value>
</Value>
<Value name="3">
<Value>refid</Value>
</Value>
<Value name="4">
<Value>start</Value>
</Value>
<Value name="5">
<Value>text</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("refspans")</DataLocation>
<DefaultData>refspansDefaultData</DefaultData>
<IdLocation>^Research.Document.backmatterC("refspans")</IdLocation>
<IndexLocation>^Research.Document79C7.refspansI</IndexLocation>
<StreamLocation>^Research.Document79C7.refspansS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

