local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)

  local id

  -- check for double labels
  for _, v in ipairs(self._hud.name_labels) do
    if v.movement == data.unit:movement() then
      id = v.id
      break
    end
  end
  
  local id = id or _add_name_label_original(self, data)
  
  local label = self:_get_name_label(id)
  local name, level, rank, color_id = HopHUD:information_by_unit(data.unit)
  HopHUD:set_name_panel_text(label.text, name, level, rank, color_id)
  label.panel:child("action"):set_color(HopHUD.colors.action)
  data.name = name
  
  self:align_teammate_name_label(label.panel, label.interact)
  
  return id
end

local add_teammate_panel_original = HUDManager.add_teammate_panel
function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
  local id = add_teammate_panel_original(self, character_name, player_name, ai, peer_id)
  
  local unit = managers.criminals:character_unit_by_name(character_name)
  if unit then
    local _, level, rank, color_id = HopHUD:information_by_unit(unit)
    HopHUD:set_teammate_name_panel(self._teammate_panels[id], player_name, level, rank, color_id)
    HopHUD:create_kill_counter(self._teammate_panels[id])
  end
  
  return id
end

local add_vehicle_name_label_original = HUDManager.add_vehicle_name_label
function HUDManager:add_vehicle_name_label(data, ...)
  local id = add_vehicle_name_label_original(self, data, ...)
  
  local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
  local panel = hud.panel:child("name_label" .. id)
  
  panel:child("text"):set_text("Vehicle " .. data.name)
  panel:child("text"):set_color(Color.white)
  panel:child("text"):set_range_color(0, 7, HopHUD.colors.level)
  panel:child("bag"):set_color(Color.white)
  panel:child("bag_number"):set_color(Color.white)
  panel:child("action"):set_color(HopHUD.colors.action)
  
  self:update_vehicle_label_by_id(id)
  
  return id
end

function HUDManager:align_teammate_name_label(panel, interact)
  local text = panel:child("text")
  local action = panel:child("action")
  local bag = panel:child("bag")
  local bag_number = panel:child("bag_number")
  local cheater = panel:child("cheater")
  local _, _, tw, th = text:text_rect()
  local _, _, aw, ah = action:text_rect()
  local _, _, cw, ch = cheater:text_rect()
  local double_radius = th + ah
  if interact:radius() ~= double_radius / 2 then
    interact._radius = double_radius / 2
    interact._circle:set_size(double_radius, double_radius)
    if interact._bg_circle then
      interact._bg_circle:set_size(double_radius, double_radius)
    end
  end
  
  panel:set_size(math.max(tw, cw) + 4 + double_radius, math.max(th + ah + ch, double_radius))
  text:set_size(tw, th)
  action:set_size(panel:w(), ah)
  cheater:set_size(cw, ch)
  text:set_x(double_radius + 4)
  action:set_x(double_radius + 4)
  cheater:set_x(double_radius + 4)
  text:set_top(cheater:bottom())
  action:set_top(text:bottom())
  bag:set_size(ch * (bag:w() / bag:h()) * 0.75, ch * 0.75)
  bag:set_top(text:top() + 2)
  interact:set_position(0, text:top())

  local infamy = panel:child("infamy")
  if infamy then
    infamy:set_size(ch * (infamy:w() / infamy:h()), ch)
    infamy:set_x(double_radius + 4)
    infamy:set_center_y(text:center_y() + infamy:h() / 8 - 1)
    panel:set_w(panel:w() + infamy:w())
    text:set_size(panel:size())
    text:set_x(double_radius + 4 + infamy:w())
  end

  if bag_number then
    bag_number:set_top(text:top())
    panel:set_w(panel:w() + bag_number:w() + bag:w() + 8)
    bag:set_right(panel:w() - bag_number:w())
    bag_number:set_right(panel:w() + 2)
  else
    panel:set_w(panel:w() + bag:w() + 4)
    bag:set_right(panel:w())
  end
end