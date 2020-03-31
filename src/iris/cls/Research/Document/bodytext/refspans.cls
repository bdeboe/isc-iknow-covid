Class Research.Document.bodytext.refspans Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

Parameter %JSONIGNOREINVALIDFIELD = 1;

Parameter %JSONIGNORENULL As BOOLEAN = 1;

Relationship bodytext As Research.Document.bodytext [ Cardinality = parent, Inverse = refspans ];

Property end As %Integer(%JSONFIELDNAME = "end");

Property refid As %String(%JSONFIELDNAME = "ref_id", MAXLEN = "");

Property start As %Integer(%JSONFIELDNAME = "start");

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
<DataLocation>{%%PARENT}("citespans")</DataLocation>
<DefaultData>refspansDefaultData</DefaultData>
<IdLocation>^Research.Document.bodytextC("citespans")</IdLocation>
<IndexLocation>^Research.Document3984.refspansI</IndexLocation>
<StreamLocation>^Research.Document3984.refspansS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

