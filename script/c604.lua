--Illusion-Eyes Restrict
--Custom card for EDOPro
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,64631466,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	--Must be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Equip on Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--ATK/DEF equal to equipped
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e4)
	--Reveal hand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_PUBLIC)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_HAND)
	e5:SetCondition(s.pubcon)
	c:RegisterEffect(e5)
end
s.listed_names={64631466}
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_HAND)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.ConfirmCards(tp,g)
		local mg=g:Filter(Card.IsMonster,nil)
		if #mg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local tc=mg:Select(tp,1,1,nil):GetFirst()
			if tc and Duel.Equip(tp,tc,c,false) then
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
		end
		Duel.ShuffleHand(1-tp)
	end
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
function s.pubcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()
	return g:IsExists(function(tc) return tc:GetFlagEffect(id)~=0 end,1,nil)
end