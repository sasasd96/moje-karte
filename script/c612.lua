--Dark Illusions-Eyes Restrict
--Custom card for EDOPro
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,64631466,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1110))
	--Must be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Equip during either turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--ATK equal to equipped
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Unaffected by opponent's effects
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.immcost)
	e4:SetOperation(s.immop)
	c:RegisterEffect(e4)
end
s.listed_names={64631466}
s.listed_series={0x110,0x1110}
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and (Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 or Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)) end
	local b1=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	elseif b2 then
		op=1
	else
		return false
	end
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local op=e:GetLabel()
	if op==0 then
		--From hand
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.ConfirmCards(tp,g)
			local mg=g:Filter(Card.IsMonster,nil)
			if #mg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local tc=mg:Select(tp,1,1,nil):GetFirst()
				if tc and Duel.Equip(tp,tc,c,false) then
					s.equipop(c,tc)
				end
			end
			Duel.ShuffleHand(1-tp)
		end
	else
		--From field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			if Duel.Equip(tp,tc,c,false) then
				s.equipop(c,tc)
			end
		end
	end
end
function s.equipop(c,tc)
	--Add Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(id)~=0 then
			if tc:IsType(TYPE_XYZ) then
				atk=atk+tc:GetBaseAttack()
			else
				atk=atk+tc:GetAttack()
			end
		end
		tc=g:GetNext()
	end
	return atk
end
function s.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(function(tc) return tc:GetFlagEffect(id)~=0 end,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,function(tc) return tc:GetFlagEffect(id)~=0 end,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end