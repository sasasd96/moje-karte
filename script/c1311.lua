--Polymerization
--Custom card (reprint)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAbleToDeck),Fusion.OnFieldMat,s.fextra,Fusion.ShuffleMaterial)
	c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil)
end