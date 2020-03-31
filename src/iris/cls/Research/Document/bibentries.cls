Class Research.Document.bibentries Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Inheritance = left, ProcedureBlock ]
{

/// The %JSONIGNOREINVALIDFIELD parameter allows the programmer to control handling of unexpected fields in the JSON input.
/// The default (%JSONIGNOREINVALIDFIELD = 0) will treat an unexpected field as an error.
/// If %JSONIGNOREINVALIDFIELD is set = 1, then unexpected fields will be ignored.
Parameter %JSONIGNOREINVALIDFIELD As BOOLEAN = 1;

Storage Default
{
<Data name="bibentriesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Research.Document.bibentriesD</DataLocation>
<DefaultData>bibentriesDefaultData</DefaultData>
<IdLocation>^Research.Document.bibentriesD</IdLocation>
<IndexLocation>^Research.Document.bibentriesI</IndexLocation>
<StreamLocation>^Research.Document.bibentriesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

