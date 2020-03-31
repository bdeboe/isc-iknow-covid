Class Demo.SetAnalysis.ComputedDimension Extends %iKnow.DeepSee.Dimensions.Base
{

Method %ComputeIndexKey(pMemberKey As %String) As %String
{
	set:$f(pMemberKey,":") pMemberKey = $piece(pMemberKey,":",*)
	Quit $ZCRC(pMemberKey,7)
}

/// Method combining the functionality of <method>%MemberSearch</method> and
/// <method>%OnGetComputedMembersFiltered</method> to avoid having the same code twice.<br/>
/// Returns entries of the form:<br/>
/// 		pMembers(n) = $lb(id, name, key)<br/>
/// Expects any predefined dimension members to supplied with <var>pMemmbers</var> upfront!
Method %OnGetComputedMembersInternal(ByRef pMembers, pSearchKey As %String = "", pRollupKey As %String = "", ByRef pRange As %String = "") As %Status [ Internal ]
{
	set tSC = $$$OK
	try {
		set tSQL = "SELECT ID, Name FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = ?"
		set:pSearchKey'="" tSQL = tSQL_" AND Name LIKE '%"_pSearchKey_"%'"
		set tStatement = ##class(%SQL.Statement).%New()
		set tSC = tStatement.%Prepare(tSQL)
		quit:$$$ISERR(tSC)
		set tResult = tStatement.%Execute(..%ikDomainId)
		while tResult.%Next() {
			set pMembers($i(pMembers)) = $lb(tResult.%Get("Name"), tResult.%Get("Name"), tResult.%Get("Name"))
		}
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

Method %FindComputedMemberByKey(pKey As %String, Output pFlag As %Boolean, Output pMemberName As %String, Output pMemberId As %String) As %Status
{
	set:$f(pKey,":") pKey = $piece(pKey,":",*)
	set tSetObj = ##class(SetDefinition).NameIdxOpen(..%ikDomainId, pKey)
	if $isobject(tSetObj) {
		set pFlag=1, pMemberName=tSetObj.Name, pMemberId=pKey
	} else {
		set pFlag=0, pMemberName="", pMemberId=""
	}
	quit ..%ComputeBitset(pKey, .tIndexKey)
}

/// Do the actual work of building the bitset.
Method %OnComputeBitset(pSpec As %String, pIndexKey As %String) As %Status
{
	set tSC = $$$OK
	try {
		set:$f(pSpec,":") pSpec = $piece(pSpec,":",*)
		set tSetObj = ##class(SetDefinition).NameIdxOpen(..%ikDomainId, pSpec)
		quit:tSetObj=""
		
		do tSetObj.GetFilter().ToBitstring(.tBits)
		
		kill $$$DeepSeeIndexGLVN(..%baseCube, ..%factNumber, pIndexKey)
		merge $$$DeepSeeIndexGLVN(..%baseCube, ..%factNumber, pIndexKey) = tBits
		
		if (..%ikDomainType = "iKnow") {
			set tIndexGlo = $name($$$DeepSeeIndexGLVN(..%baseCube, ..%factNumber, pIndexKey))
			set tSC = ##class(%iKnow.DeepSee.CubeUtils).TranslateIKnowBitstring(..%baseCube, ..%ikMeasure, tIndexGlo)
			quit:$$$ISERR(tSC)
		}
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod %Count(pCube As %String, pDimNo As %Integer, pHierNo As %Integer, pLevelNo As %Integer) As %Integer
{
	set tSC = $$$OK, tCount = 0
	try {
		set tCube = $$$UPPER(pCube)
		
		// count number of pre-defined members
		set tSC = ..%GetPredefinedMembers(.tMembers, pCube, pDimNo, pHierNo, pLevelNo)
		quit:$$$ISERR(tSC)
		set i = ""
		for {
			set i = $order(tMembers(i))
			quit:i=""
			set tCount = tCount + 1
		}
		quit:tCount
		
		// if none predefined, query domain
		do ##class(%DeepSee.Utils).%GetDimensionFact(pCube, pDimNo, pHierNo, pLevelNo, .tFactName)
		if (tFactName'="") {
			set tIKMeasure = $g($$$DeepSeeMetaGLVN("cubes", tCube, "fact", "prop", tFactName, "iKnowMsr"))
			if (tIKMeasure'="") {
				set tDomainId = ##class(%iKnow.DeepSee.CubeUtils).GetDomainId(pCube, tIKMeasure)
				if (tDomainId) {
					&SQL(SELECT COUNT(*) INTO :tCount FROM Demo_SetAnalysis.SetDefinition WHERE DomainId = :tDomainId)
					if (SQLCODE=0) {}
					elseif (SQLCODE=100) { set tCount = 0 }
					else { set tSC = ##class(%SYSTEM.Error).FromSQLCode(SQLCODE).Status  quit }
				}	
			}
		}
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tCount
}

Parameter CACHECOMPUTEDBITSET = "NEVER";

/// Resolve any special tokens or expression in a key value and return the result.
Method %ResolveKey(pSpec As %String, Output pRKey As %String) As %Status
{
	Set tSC = $$$OK
	Set pRKey = $piece(pSpec,":",*)
	Quit tSC
}

}

