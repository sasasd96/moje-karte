--Black Illusion Magic
--Custom card for EDOPro
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish from GY for protection
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.protop)
	c:RegisterEffect(e2)
end
s.listed_names={64631466}
s.listed_series={0x110,0x1110}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsCode(64631466) or c:IsSetCard(0x110,0x1110)) 
		and c:IsType(TYPE_FUSION) and c:GetEquipGroup():IsExists(Card.IsMonster,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local eq=tc:GetEquipGroup():Filter(Card.IsMonster,nil)
		if #eq>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local eqc=eq:Select(tp,1,1,nil):GetFirst()
			Duel.Remove(eqc,POS_FACEUP,REASON_COST)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.protfilter(c)
	return c:IsFaceup() and (c:IsCode(64631466) or c:IsSetCard(0x1110)) and c:IsType(TYPE_FUSION)
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.protfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		local c=e:GetHandler()
		for tc in aux.Next(g) do
			--Cannot be destroyed by battle
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3008)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			--Cannot be destroyed by effects
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetDescription(3001)
			tc:RegisterEffect(e2)
		end
	end
end