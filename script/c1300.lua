--Zorc Necrophades, God of Darkness
--Custom card
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DIVINE),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	--Cannot be Special Summoned except by Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Always treated as DIVINE attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
	e2:SetValue(ATTRIBUTE_DIVINE)
	c:RegisterEffect(e2)
	--Cannot be tributed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	--Unaffected by opponent's card effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
	--Negate opponent monster effects
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(s.distg)
	c:RegisterEffect(e6)
	--Attack all monsters
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_ATTACK_ALL)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	--Damage when destroying monster
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_BATTLE_DESTROYING)
	e8:SetCondition(aux.bdcon)
	e8:SetOperation(s.damop)
	c:RegisterEffect(e8)
	--Direct attack win condition
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e9:SetCode(EVENT_BATTLE_DAMAGE)
	e9:SetCondition(s.wincon)
	e9:SetOperation(s.winop)
	c:RegisterEffect(e9)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.distg(e,c)
	return c:IsType(TYPE_MONSTER) and not c:IsAttribute(ATTRIBUTE_DIVINE)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc then
		local dam=bc:GetAttack()
		if dam<0 then dam=0 end
		Duel.Damage(1-tp,800,REASON_EFFECT)
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_EXODIA)
end