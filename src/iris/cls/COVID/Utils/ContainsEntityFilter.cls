Class COVID.Utils.ContainsEntityFilter Extends %iKnow.Filters.ContainsEntityFilter [ Language = objectscript ]
{

/// Workaround for extrinsic function error
Method GetEntities(Output pCount As %Integer) As %List
{
	set l = "", pCount = 0
	if $d(i%Entities)>1 {
		set e = ""
		for {
			set e = $o(i%Entities(e))
			quit:e=""
			set l = l_$lb(e), pCount=pCount+1
		}
	} else {
		set l = i%Entities, pCount = $ll(l)
	}
	quit l
}

}

