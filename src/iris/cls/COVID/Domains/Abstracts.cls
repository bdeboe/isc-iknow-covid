Class COVID.Domains.Abstracts Extends %iKnow.DomainDefinition
{

/// <p>An XML representation of the domain this class defines.</p>
/// <p>For a detailed reference of the available elements and attributes, consult the class
/// reference for <class>%iKnow.Model.domain</class> and other classes in the <package>%iKnow.Model</package>
/// package.</p>
XData Domain [ XMLNamespace = "http://www.intersystems.com/iknow" ]
{
<domain name="COVID-19 Abstracts">
<configuration name="Abstracts-ALI" detectLanguage="true" languages="en,fr,es,de,nl,pt" />
<metadata>
<field name="PaperID"/>
<field name="Source" storage="1" />
<field name="Title" />
</metadata>
<data>
<query sql="SELECT %ID as ID, * FROM Research.FullDocument" 
 idField="ID" groupField="Source" dataFields="Abstract"
 metadataFields="PaperID,Source,Title"
 metadataColumns="PaperID,Source,Title"
 configuration="Abstracts-ALI" >
 </query>
</data>
</domain>
}

}

