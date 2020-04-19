Class Research.FullDocument Extends %Persistent [ Language = objectscript ]
{

Parameter USEEXTENTSET = 1;

Property Source As %String(MAXLEN = 200);

Property PaperID As %String(MAXLEN = 200);

Property Title As %String(MAXLEN = 1000);

Property Filename As %String(MAXLEN = 1000);

Property Abstract As %Stream.GblChrCompress;

Property BodyText As %Stream.GblChrCompress;

Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($ZTIMESTAMP,3,1,3)}, Required ];

Property BodyHash As %Integer;

Index idxHash On BodyHash;

Index idxSource On Source [ Type = bitmap ];

Index idxPaper On PaperID;

Index idxAbstract On (Abstract) As %iFind.Index.Analytic;

Index idxBody On (BodyText) As %iFind.Index.Analytic;

Storage Default
{
<Data name="FullDocumentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Source</Value>
</Value>
<Value name="3">
<Value>PaperID</Value>
</Value>
<Value name="4">
<Value>Title</Value>
</Value>
<Value name="5">
<Value>Filename</Value>
</Value>
<Value name="6">
<Value>Abstract</Value>
</Value>
<Value name="7">
<Value>BodyText</Value>
</Value>
<Value name="8">
<Value>CreatedAt</Value>
</Value>
<Value name="9">
<Value>BodyHash</Value>
</Value>
</Data>
<DataLocation>^DCG2.YPjm.1</DataLocation>
<DefaultData>FullDocumentDefaultData</DefaultData>
<ExtentLocation>^DCG2.YPjm</ExtentLocation>
<IdLocation>^DCG2.YPjm.1</IdLocation>
<Index name="$FullDocument">
<Location>^DCG2.YPjm.2</Location>
</Index>
<Index name="IDKEY">
<Location>^DCG2.YPjm.1</Location>
</Index>
<Index name="idxAbstract">
<Location>^DCG2.YPjm.3</Location>
</Index>
<Index name="idxBody">
<Location>^DCG2.YPjm.4</Location>
</Index>
<Index name="idxHash">
<Location>^DCG2.YPjm.7</Location>
</Index>
<Index name="idxPaper">
<Location>^DCG2.YPjm.5</Location>
</Index>
<Index name="idxSource">
<Location>^DCG2.YPjm.6</Location>
</Index>
<IndexLocation>^DCG2.YPjm.I</IndexLocation>
<StreamLocation>^DCG2.YPjm.S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

