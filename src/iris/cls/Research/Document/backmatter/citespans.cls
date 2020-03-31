Class Research.Document.backmatter.citespans Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship backmatter As Research.Document.backmatter [ Cardinality = parent, Inverse = citespans ];

Property end As %Numeric(%JSONFIELDNAME = "end", SCALE = 0);

Property refid As %String(%JSONFIELDNAME = "ref_id", MAXLEN = "");

Property start As %Numeric(%JSONFIELDNAME = "start", SCALE = 0);

Property text As %String(%JSONFIELDNAME = "text", MAXLEN = "");

Storage Default
{
<Data name="citespansDefaultData">
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
<DataLocation>{%%PARENT}("citespans")</DataLocation>
<DefaultData>citespansDefaultData</DefaultData>
<IdLocation>^Research.Document.backmatterC("citespans")</IdLocation>
<IndexLocation>^Research.Documen79C7.citespansI</IndexLocation>
<StreamLocation>^Research.Documen79C7.citespansS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

