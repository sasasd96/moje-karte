--Orichalcos Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x12ab),nil,s.fcheck,Fusion.OnFieldMat(Card.IsAbleToRemove),s.gcheck,nil,nil,nil,nil,nil,nil,nil,nil,s.extrafil)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end
s.listed_series={0x12ab}
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x12ab)
end
function s.gcheck(sg)
	return sg:IsExists(Card.IsSetCard,1,nil,0x12ab)
end
function s.exfilter(c)
	return c:IsSetCard(0x12ab) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsFaceup()
end
function s.extrafil(e,tp,mg)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x12ab),tp,LOCATION_FZONE,0,1,nil) then
		return Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
	end
	return nil
end