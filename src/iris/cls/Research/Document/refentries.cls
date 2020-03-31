Class Research.Document.refentries Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

/// The %JSONIGNOREINVALIDFIELD parameter allows the programmer to control handling of unexpected fields in the JSON input.
/// The default (%JSONIGNOREINVALIDFIELD = 0) will treat an unexpected field as an error.
/// If %JSONIGNOREINVALIDFIELD is set = 1, then unexpected fields will be ignored.
Parameter %JSONIGNOREINVALIDFIELD As BOOLEAN = 1;

Storage Default
{
<Data name="refentriesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Research.Document.refentriesD</DataLocation>
<DefaultData>refentriesDefaultData</DefaultData>
<IdLocation>^Research.Document.refentriesD</IdLocation>
<IndexLocation>^Research.Document.refentriesI</IndexLocation>
<StreamLocation>^Research.Document.refentriesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

