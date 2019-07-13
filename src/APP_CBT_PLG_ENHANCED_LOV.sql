create or replace package APP_CBT_PLG_ENHANCED_LOV as
  procedure render (
      p_item   in            apex_plugin.t_item,
      p_plugin in            apex_plugin.t_plugin,
      p_param  in            apex_plugin.t_item_render_param,
      p_result in out nocopy apex_plugin.t_item_render_result 
  );

  procedure ajax(
    p_item   in            apex_plugin.t_item,
    p_plugin in            apex_plugin.t_plugin,
    p_param  in            apex_plugin.t_item_ajax_param,
    p_result in out nocopy apex_plugin.t_item_ajax_result 
  );
end APP_CBT_PLG_ENHANCED_LOV;
