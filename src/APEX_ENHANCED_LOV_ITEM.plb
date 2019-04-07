create or replace package body APEX_ENHANCED_LOV_ITEM as

  g_app_id  number default v('APP_ID');
  g_page_id number default v('APP_PAGE_ID');
  g_debug   boolean default case when v('DEBUG') = 'YES' then true else false end;
  g_ajax_mode varchar2(4000);

  g_ajax_search_string varchar2(4000);
  g_ajax_search_column_idx number;

  g_item   apex_plugin.t_page_item;
  g_plugin apex_plugin.t_plugin;

  --
  -- function prepareSqlQuery
  --
  function prepareSqlQuery return varchar2
  is
    v_query varchar2(32767) := g_item.lov_definition;
  begin
    /*
      queries generated by APEX for static inline lov and static shared lov
    */
    --select /*+ cardinality(t 5) no_result_cache */ disp, val from table(wwv_flow_utilities.get_temp_lov_data(1)) t order by disp
    --select /*+ cardinality(t 10) no_result_cache */ disp, val from table(wwv_flow_utilities.get_temp_lov_data(1)) t order by insert_order, disp

    if  instr(v_query, '*/ disp, val from') > 0  then
      v_query := '
        /*1*/
        select disp d, val r from (
          '||v_query||'
        ) /*2*/
      ';
    end if;

    return v_query;
  end prepareSqlQuery;

  --
  -- getBindedRefCursor
  --

  function getBindedRefCursor(
    pi_sql in varchar2
  ) return sys_refcursor as
    v_apex_items_names    DBMS_SQL.VARCHAR2_TABLE;
    v_cursor              pls_integer;
    v_status              number;
  begin
    v_apex_items_names := WWV_FLOW_UTILITIES.GET_BINDS( pi_sql );

    -- open v_cursor;
    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse (v_cursor, pi_sql, dbms_sql.native);

    -- bind items
    for i in 1..v_apex_items_names.count loop
      
      if v_apex_items_names(i) = ':SEARCH_STRING' then
        dbms_sql.bind_variable (v_cursor, v_apex_items_names(i), g_ajax_search_string );
      else
        dbms_sql.bind_variable (v_cursor, v_apex_items_names(i), v( trim(both ':' from v_apex_items_names(i)) ) );
      end if;
      
    end loop;

    v_status := dbms_sql.execute(v_cursor);

    return dbms_sql.to_refcursor(v_cursor);  
  end getBindedRefCursor;

  --
  -- t_item_render_param_to_json
  --
  
  function t_item_render_param_to_json(
    p_param in apex_plugin.t_item_render_param
  ) return clob is 

    v_clob clob;
  begin
    apex_json.initialize_clob_output;
    apex_json.open_object;
    
    apex_json.write('value_set_by_controller', p_param.value_set_by_controller);
    apex_json.write('value', p_param.value);
    apex_json.write('is_readonly', p_param.is_readonly);
    apex_json.write('is_printer_friendly', p_param.is_printer_friendly );

    apex_json.close_object;

    v_clob := apex_json.get_clob_output;

    apex_json.free_output;

    return v_clob;
  end t_item_render_param_to_json;

  --
  -- t_plugin_to_json
  --

  function t_plugin_to_json(
    p_plugin in apex_plugin.t_plugin
  ) return clob is 
    v_clob clob;
  begin
    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('name', p_plugin.name);
    apex_json.write('file_prefix', p_plugin.file_prefix);
    apex_json.write('ajaxIdentifier', apex_plugin.get_ajax_identifier);
    apex_json.write('attribute_01', p_plugin.attribute_01);
    apex_json.write('attribute_02', p_plugin.attribute_02);
    apex_json.write('attribute_03', p_plugin.attribute_03);
    apex_json.write('attribute_04', p_plugin.attribute_04);
    apex_json.write('attribute_05', p_plugin.attribute_05);
    apex_json.write('attribute_06', p_plugin.attribute_06);
    apex_json.write('attribute_07', p_plugin.attribute_07);
    apex_json.write('attribute_08', p_plugin.attribute_08);
    apex_json.write('attribute_09', p_plugin.attribute_09);
    apex_json.write('attribute_10', p_plugin.attribute_10);
    apex_json.write('attribute_11', p_plugin.attribute_11);
    apex_json.write('attribute_12', p_plugin.attribute_12);
    apex_json.write('attribute_13', p_plugin.attribute_13);
    apex_json.write('attribute_14', p_plugin.attribute_14);
    apex_json.write('attribute_15', p_plugin.attribute_15);

    apex_json.close_object;

    v_clob := apex_json.get_clob_output;

    apex_json.free_output;

    return v_clob;
  end t_plugin_to_json;
  --
  -- t_page_item_to_json
  --
  function t_page_item_to_json(
    p_item in apex_plugin.t_item
  ) return clob
  is
    v_clob clob;
  begin

    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('id', p_item.id);
    apex_json.write('name', p_item.name);
    apex_json.write('label', p_item.label);
    apex_json.write('plain_label', p_item.plain_label);
    apex_json.write('label_id', p_item.label_id);
    apex_json.write('placeholder', p_item.placeholder);
    apex_json.write('format_mask', p_item.format_mask);
    apex_json.write('is_required', p_item.is_required);
    apex_json.write('lov_definition', p_item.lov_definition);
    apex_json.write('lov_display_extra', p_item.lov_display_extra);
    apex_json.write('lov_display_null', p_item.lov_display_null);
    apex_json.write('lov_null_text', p_item.lov_null_text);
    apex_json.write('lov_null_value', p_item.lov_null_value);
    apex_json.write('lov_cascade_parent_items', p_item.lov_cascade_parent_items);
    apex_json.write('ajax_items_to_submit', p_item.ajax_items_to_submit);
    apex_json.write('ajax_optimize_refresh', p_item.ajax_optimize_refresh);
    apex_json.write('element_width', p_item.element_width);
    apex_json.write('element_max_length', p_item.element_max_length);
    apex_json.write('element_height', p_item.element_height);
    apex_json.write('element_css_classes', p_item.element_css_classes);
    apex_json.write('element_attributes', p_item.element_attributes);
    apex_json.write('element_option_attributes', p_item.element_option_attributes);
    apex_json.write('escape_output', p_item.escape_output);
    apex_json.write('attribute_01', p_item.attribute_01);
    apex_json.write('attribute_02', p_item.attribute_02);
    apex_json.write('attribute_03', p_item.attribute_03);
    apex_json.write('attribute_04', p_item.attribute_04);
    apex_json.write('attribute_05', p_item.attribute_05);
    apex_json.write('attribute_06', p_item.attribute_06);
    apex_json.write('attribute_07', p_item.attribute_07);
    apex_json.write('attribute_08', p_item.attribute_08);
    apex_json.write('attribute_09', p_item.attribute_09);
    apex_json.write('attribute_10', p_item.attribute_10);
    apex_json.write('attribute_11', p_item.attribute_11);
    apex_json.write('attribute_12', p_item.attribute_12);
    apex_json.write('attribute_13', p_item.attribute_13);
    apex_json.write('attribute_14', p_item.attribute_14);
    apex_json.write('attribute_15', p_item.attribute_15);

    apex_json.close_object;

    v_clob := apex_json.get_clob_output;

    apex_json.free_output;

    return v_clob;
  end t_page_item_to_json;

  --
  -- function f_queryGetColumnType
  --
  function f_queryGetColumnType(
    p_col_type in number
  ) return varchar2 is 
    l_col_type varchar2(50);
  begin
    if p_col_type = 1 then
      l_col_type := 'VARCHAR2';

    elsif p_col_type = 2 then
      l_col_type := 'NUMBER';

    elsif p_col_type = 12 then
      l_col_type := 'DATE';
        
    elsif p_col_type in (180,181,231) then
      l_col_type := 'TIMESTAMP';

      if p_col_type = 231 then
          l_col_type := 'TIMESTAMP_LTZ';
      end if;

    elsif p_col_type = 112 then
      l_col_type := 'CLOB';

    elsif p_col_type = 113 then

      l_col_type := 'BLOB';

    elsif p_col_type = 96 then
      l_col_type := 'CHAR';

    else
        l_col_type := 'OTHER';
    end if;

    return l_col_type;

  end f_queryGetColumnType;

  --
  -- procedure p_queryDescribeColumns
  --
  procedure p_queryDescribeColumns(
    pi_sql              in  varchar2,
    po_columns_no       out number,
    po_columns_info_arr out sys.dbms_sql.desc_tab2
  ) 
  is
    v_apex_items_names  DBMS_SQL.VARCHAR2_TABLE := WWV_FLOW_UTILITIES.GET_BINDS( pi_sql );
    v_cursor            pls_integer;
    v_desc_col_no       number          := 0;
    v_desc_col_info     sys.dbms_sql.desc_tab2;  
    v_status            number;

  begin
    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse ( v_cursor, pi_sql, dbms_sql.native);

    --bind items
    for i in 1..v_apex_items_names.count loop
      dbms_sql.bind_variable (v_cursor, v_apex_items_names(i), v( trim(both ':' from v_apex_items_names(i)) ) );
    end loop;

    sys.dbms_sql.describe_columns2( v_cursor, v_desc_col_no, v_desc_col_info);

    v_status := dbms_sql.execute(v_cursor);

    po_columns_no       := v_desc_col_no;
    po_columns_info_arr := v_desc_col_info;

  end p_queryDescribeColumns;

  --
  -- function f_queryPrepareConditions
  --
  function f_queryPrepareConditions(
    pi_sql in varchar2
  ) return varchar2
  is
    v_desc_col_no   number          := 0;
    v_desc_col_info sys.dbms_sql.desc_tab2;  
    v_return        varchar2(32767);
  begin
    p_queryDescribeColumns(
      pi_sql              => pi_sql,
      po_columns_no       => v_desc_col_no,
      po_columns_info_arr => v_desc_col_info
    );

    if g_ajax_search_column_idx is not null then
      --search by specific column
      v_return := 'where upper('||v_desc_col_info(g_ajax_search_column_idx).col_name||') like upper(''%''||:SEARCH_STRING||''%'')';
    else
      --search by every column from query
      v_return := 'where ';

      for i in 1..v_desc_col_no loop
        v_return := v_return||' upper('||v_desc_col_info(i).col_name||') like upper(''%''||:SEARCH_STRING||''%'') or';
      end loop;

      v_return := rtrim(v_return, ' or');

    end if;

    return v_return;
  end f_queryPrepareConditions;

  --
  -- f_queryGetColumnsJson
  --

  function f_queryGetColumnsJson return clob is
    v_return        CLOB;
    v_desc_col_no   number          := 0;
    v_desc_col_info sys.dbms_sql.desc_tab2;  
  begin
    p_queryDescribeColumns(
      pi_sql              => prepareSqlQuery,
      po_columns_no       => v_desc_col_no,
      po_columns_info_arr => v_desc_col_info
    );
    
    apex_json.initialize_clob_output;
    apex_json.open_array;

    for i in 1..v_desc_col_no loop
      apex_json.open_object;
      apex_json.write('COLUMN_NAME', v_desc_col_info(i).col_name);
      apex_json.write('COLUMN_TYPE', f_queryGetColumnType( v_desc_col_info(i).col_type ) );
      apex_json.write('SHEMA_NAME', v_desc_col_info(i).col_schema_name, true );
      apex_json.write('IDX', i );
       
      apex_json.close_object;
    end loop;

    apex_json.close_array;

    v_return := apex_json.get_clob_output;

    apex_json.free_output;

    return v_return;
  end f_queryGetColumnsJson;

  --
  -- f_getDisplayValues
  --
  function f_getDisplayValues(
    pi_value in varchar2
  ) return varchar2
  is
    v_cursor sys_refcursor;
    v_result varchar2(32767);
    v_query  varchar2(32767);
  begin
    v_query := '
      select 
        listagg(d, '', '') within group( order by d asc )
      from (
        '||prepareSqlQuery||'
      ) 
      where
        r in ('||''''||replace(pi_value, ':', ''',''')||''''||')
    ';

    v_cursor := getBindedRefCursor( v_query );

    FETCH v_cursor INTO v_result;

    CLOSE v_cursor;

    return v_result;
  end f_getDisplayValues;

  --
  -- f_autocompleteGetDefaulsSearch
  --

  function f_autocompleteGetDefaulsSearch return varchar2
  is 
    v_attr_autocomplete_d_search  APEX_APPLICATION_PAGE_ITEMS.attribute_04%type := g_item.attribute_04;
    v_conditions                  varchar2(32767);
  begin

    if v_attr_autocomplete_d_search = 'D%' then
      v_conditions := v_conditions||' 
        and upper(d) like upper(:SEARCH_STRING||''%'') 
      ';
    end if;

    if v_attr_autocomplete_d_search = '%D' then
      v_conditions := v_conditions||' 
        and upper(d) like upper(''%''||:SEARCH_STRING) 
      ';
    end if;

    if v_attr_autocomplete_d_search = '%D%' then
      v_conditions := v_conditions||' 
        and upper(d) like upper(''%''||:SEARCH_STRING||''%'') 
      ';
    end if;

    if v_attr_autocomplete_d_search = 'D' then
      v_conditions := v_conditions||' 
        and upper(d) = upper(:SEARCH_STRING) 
      ';
    end if;

    if v_attr_autocomplete_d_search = 'R%' then
      v_conditions := v_conditions||' 
        and upper(r) like upper(:SEARCH_STRING||''%'') 
      ';
    end if;

    if v_attr_autocomplete_d_search = '%R' then
      v_conditions := v_conditions||' 
        and upper(r) like upper(''%''||:SEARCH_STRING) 
      ';
    end if;

    if v_attr_autocomplete_d_search = '%R%' then
      v_conditions := v_conditions||' 
        and upper(r) like upper(''%''||:SEARCH_STRING||''%'') 
      ';
    end if;

    if v_attr_autocomplete_d_search = 'R' then
      v_conditions := v_conditions||' 
        and upper(R) = upper(:SEARCH_STRING) 
      ';
    end if;

    if v_attr_autocomplete_d_search = 'DR%' then
      v_conditions := v_conditions||' 
        and (
          upper(r) like upper(:SEARCH_STRING||''%'')
          or upper(d) like upper(:SEARCH_STRING||''%'')
        )
      ';
    end if;

    if v_attr_autocomplete_d_search = '%DR' then
      v_conditions := v_conditions||' 
        and (
          upper(r) like upper(''%''||:SEARCH_STRING)
          or upper(d) like upper(''%''||:SEARCH_STRING)
        )
      ';
    end if;

    if v_attr_autocomplete_d_search = '%DR%' then
      v_conditions := v_conditions||' 
        and (
          upper(r) like upper(''%''||:SEARCH_STRING||''%'')
          or upper(d) like upper(''%''||:SEARCH_STRING||''%'')
        )
      ';
    end if;

    if v_attr_autocomplete_d_search = 'DR' then
      v_conditions := v_conditions||' 
        and (
          upper(r) = upper(:SEARCH_STRING)
          or upper(d) = upper(:SEARCH_STRING)
        )
      ';
    end if;  

    return v_conditions;
  end f_autocompleteGetDefaulsSearch;

  --
  -- function f_getRownumLimiterStart
  --
  function f_getRownumLimiterStart(
    p_page          in number,
    p_rows_per_page in number
  ) return number
  is
    v_start_rownum_with number;
    v_start_rownum      number;
  begin
    v_start_rownum_with := (p_page-1)*p_rows_per_page+1;

    if v_start_rownum_with = 0 then
      v_start_rownum := 1;
    else
      v_start_rownum := v_start_rownum_with;
    end if;

    return v_start_rownum;

  end f_getRownumLimiterStart;

  --
  -- f_popupGetCurrentPageDataCount
  --

  function f_popupGetCurrentPageDataCount(
    pi_where in varchar2
  ) return number 
  is
    v_cursor  sys_refcursor;
    v_result  number;
    v_query   varchar2(4000);
  begin
    v_cursor :=  getBindedRefCursor( 'select count(1) from ('||prepareSqlQuery||') '||pi_where );

    FETCH v_cursor INTO v_result;

    CLOSE v_cursor;

    return v_result;
  end f_popupGetCurrentPageDataCount;

  --
  -- f_queryRemoveOrderBy
  --
  function f_queryRemoveOrderBy(
    pi_sql_query in varchar2
  ) return varchar2 is
  begin
    return REGEXP_REPLACE(pi_sql_query, '(\s{0,})order(\s{1,})by(\s{1,})([^\sdecode])(.*)|(\s{1,})(order(\s{1,})by(\s{1,})decode\([^\)]*\))', '');
  end f_queryRemoveOrderBy;

  --
  -- p_ajax_getReturnValues
  --

  procedure p_ajax_getReturnValues is
    v_query      varchar2(32767) := g_item.lov_definition;
    v_where      varchar2(32767);
    v_ref_cursor sys_refcursor;
  begin

    if g_ajax_search_string is not null then
      v_where := f_queryPrepareConditions( v_query );
    end if;


    v_query := '
      select
        r
      from (
        '||v_query||'
      )
      '||v_where||'
    ';

    v_ref_cursor := getBindedRefCursor(v_query);

    apex_json.open_object;
    
    if g_debug then
      apex_json.write( 'query', v_query, true );
    end if;

    apex_json.write( 'searchString', g_ajax_search_string, true );
    apex_json.write( 'searchColumnIdx', g_ajax_search_column_idx, true );
    apex_json.write( 'data', v_ref_cursor );    
    
    apex_json.close_object;  

  end p_ajax_getReturnValues;

  --
  -- f_queryAutocomplete
  --
  function f_queryAutocomplete(
    pi_rownum_start in varchar2,
    pi_rownum_end   in varchar2
  ) return varchar2 is
    v_lov_query varchar2(32767);  
    v_query     varchar2(32767);

    v_attr_autocomplete_settings APEX_APPLICATION_PAGE_ITEMS.attribute_01%type := g_item.attribute_01;
    v_attr_autocomplete_search   APEX_APPLICATION_PAGE_ITEMS.attribute_02%type := g_item.attribute_02;
    
  begin
    v_lov_query := f_queryRemoveOrderBy( prepareSqlQuery );

    v_query := '
      select 
        * 
      from ( 
        '||v_lov_query||' 
      ) 
      where
        1=1
    ';

    if instr(v_attr_autocomplete_settings, 'UCSL') > 0 then
      --custom search
      v_query := v_query ||' '||v_attr_autocomplete_search||'';
    else
      --default search
      v_query := v_query ||f_autocompleteGetDefaulsSearch();
    end if;

    return '
      select 
        *
      from (
        select 
          a.*, 
          rownum pretius_rnum
        from (
          /**/
          '||v_query||'
          /**/
        ) a
        where rownum <= '||pi_rownum_end||'
      )
      where pretius_rnum >= '||pi_rownum_start||'
    ';
  end f_queryAutocomplete;



  --
  -- f_query_popupSelected
  --
  function f_query_popupSelected(
    pi_collection_name in varchar2,
    pi_query           in varchar2
  ) return varchar2 is
  begin
   return '
      select
        query.* 
      from 
        apex_collections
      join (
        '||pi_query||'
      ) query
      on
        c001 = r
      where
        collection_name = '''||pi_collection_name||'''
    ';
  end f_query_popupSelected;


  --
  -- p_ajax_getSessionState
  --    
  procedure p_ajax_getSessionState is
    v_selected_arr    APEX_APPLICATION_GLOBAL.VC_ARR2;
    v_collection_name APEX_COLLECTIONS.COLLECTION_NAME%TYPE := g_item.name||'_SHOWSELECTED';

    v_session_value   varchar2(4000) := v(g_item.name);
    v_query           varchar2(32767);

    v_ref_cursor      sys_refcursor;
  begin

    v_selected_arr := APEX_UTIL.STRING_TO_TABLE (
      p_string    => v_session_value,
      p_separator => ':'
    );

    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION( v_collection_name );
    
    APEX_COLLECTION.ADD_MEMBERS(
      p_collection_name => v_collection_name,
      p_c001            => v_selected_arr
    );

    v_query := f_queryRemoveOrderBy( prepareSqlQuery );

    v_query := f_query_popupSelected(
      pi_collection_name => v_collection_name,
      pi_query           => v_query
    );

    open v_ref_cursor for v_query;

    apex_json.open_object;
    
    if g_debug then
      apex_json.write( 'query', v_query, true );
    end if;

    apex_json.write( 'request', g_ajax_mode, true );
    apex_json.write( 'data', v_ref_cursor );
    apex_json.write( 'session', v_session_value);
    
    apex_json.close_object;
  end p_ajax_getSessionState;

  --
  --  p_ajax_autocomplete
  --
  procedure p_ajax_autocomplete 
  is
    v_ref_cursor sys_refcursor;

    v_rows_per_page number default to_number(v('APP_AJAX_X02'));
    v_page          number default to_number(v('APP_AJAX_X04'));
    v_start_rownum  number;
    v_end_rownum    number;

    v_query         varchar2(32767);
  begin

    v_start_rownum := f_getRownumLimiterStart(
      p_page => v_page,
      p_rows_per_page => v_rows_per_page
    );
    
    v_end_rownum := v_start_rownum + v_rows_per_page;

    v_query := f_queryAutocomplete(
      pi_rownum_start => v_start_rownum,
      pi_rownum_end   => v_end_rownum
    );

    v_ref_cursor := getBindedRefCursor(v_query);

    apex_json.open_object;
    
    if g_debug then
      apex_json.write( 'query', v_query, true );
    end if;

    apex_json.write( 'request',       g_ajax_mode, true );
    apex_json.write( 'searchString',  g_ajax_search_string, true );
    apex_json.write( 'rownumStart',   v_start_rownum, true );
    apex_json.write( 'rownumEnd',     v_end_rownum , true );
    apex_json.write( 'requestedPage', v_page , true );
    apex_json.write( 'rowsPerPage',   v_rows_per_page , true );
    apex_json.write( 'data',          v_ref_cursor );
    
    apex_json.close_object;

  end p_ajax_autocomplete;  

  --
  -- p_ajax_popup_report
  --
  procedure p_ajax_popup_report is
    v_rows_per_page       number default to_number(v('APP_AJAX_X02'));
    v_page                number default to_number(v('APP_AJAX_X04'));
    v_sortColumnIdx       number default to_number(v('APP_AJAX_X05'));
    v_start_rownum        number;
    v_end_rownum          number;

    v_sortColumnDirection varchar2(4) default v('APP_AJAX_X06');
    v_query               varchar2(32767);
    v_order_by            varchar2(4000);
    v_where               varchar2(32767);
    e_msg                 varchar2(4000);

    v_ref_cursor          sys_refcursor;
    e_open_ref_cursor     exception;
  begin
    v_start_rownum := f_getRownumLimiterStart(
      p_page => v_page,
      p_rows_per_page => v_rows_per_page
    );

    v_end_rownum := v_start_rownum + v_rows_per_page -1;

    v_query := prepareSqlQuery;

    v_query := replace(v_query, chr(9), ' ');
    v_query := replace(v_query, chr(10)||chr(13), ' ');
    v_query := replace(v_query, chr(10), ' ');
    v_query := replace(v_query, chr(13), ' ');

    if  instr(v_query, '*/ disp, val from') = 0  then
      v_query := f_queryRemoveOrderBy( v_query );
    end if;

    if v_sortColumnIdx is not null then
      v_order_by := 'order by '||v_sortColumnIdx||' '||v_sortColumnDirection||'';
    end if;

    if g_ajax_search_string is not null then
      v_where := f_queryPrepareConditions( v_query );
    end if;

    v_query := '
      select 
        *
      from (
        select 
          a.*, 
          rownum pretius_rnum
        from (
          select
            *
          from (
            '||v_query||'
          )
          '||v_where||'
          '||v_order_by||'
        ) a
        where rownum <= '||v_end_rownum||'
      )
      where 
        pretius_rnum >= '||v_start_rownum||'
    ';

    v_ref_cursor := getBindedRefCursor(v_query);

    apex_json.open_object;
    
    if g_debug then
      apex_json.write( 'query', v_query, true );
    end if;

    apex_json.write( 'request', g_ajax_mode, true );
    apex_json.write( 'searchString', g_ajax_search_string, true );
    apex_json.write( 'rownumStart', v_start_rownum, true );
    apex_json.write( 'rownumEnd', v_end_rownum, true );
    apex_json.write( 'requestedPage', v_page, true );
    apex_json.write( 'rowsPerPage', v_rows_per_page, true );
    apex_json.write( 'sortByColumnIdx', v_sortColumnIdx, true );
    apex_json.write( 'sortByColumnDirection', v_sortColumnDirection, true );
    apex_json.write( 'searchColumnIdx', g_ajax_search_column_idx, true );
    apex_json.write( 'totalCount', f_popupGetCurrentPageDataCount( v_where ) );
    apex_json.write( 'data', v_ref_cursor );  
    
    apex_json.close_object;

  end p_ajax_popup_report;  

  --
  -- p_ajax_popup_selected
  --    
  procedure p_ajax_popup_selected is
    v_selected_arr    APEX_APPLICATION_GLOBAL.VC_ARR2 default APEX_APPLICATION.G_F01;
    v_collection_name APEX_COLLECTIONS.COLLECTION_NAME%TYPE := g_item.name||'_SHOWSELECTED';

    v_ref_cursor sys_refcursor;
    v_query      varchar2(32000);
  begin
    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION( v_collection_name );
    
    APEX_COLLECTION.ADD_MEMBERS(
      p_collection_name => v_collection_name,
      p_c001 => v_selected_arr
    );

    v_query := f_queryRemoveOrderBy( prepareSqlQuery );

    v_query := f_query_popupSelected(
      pi_collection_name => v_collection_name,
      pi_query           => v_query
    );

    open v_ref_cursor for v_query;

    apex_json.open_object;
    
    if g_debug then
      apex_json.write( 'query', v_query, true );
    end if;

    apex_json.write( 'request', g_ajax_mode, true );
    apex_json.write( 'data', v_ref_cursor );  
    
    apex_json.close_object;

  end p_ajax_popup_selected;


  --
  -- procedure render
  --

  procedure render (
    p_item   in            apex_plugin.t_item,
    p_plugin in            apex_plugin.t_plugin,
    p_param  in            apex_plugin.t_item_render_param,
    p_result in out nocopy apex_plugin.t_item_render_result 
  ) is
    v_debug_prefix        varchar2(100)   := '# '||p_plugin.name;
    v_item_name           varchar2(4000)  := p_item.name;
    v_is_required         varchar2(8)     := case when p_item.is_required then 'required' else null end;
    v_item_value          varchar2(32767) := p_param.value;
    v_popup_default_icon  varchar2(50)    := 'fa-list-ul';
    v_item_name_attr      varchar2(32767);    
    v_item_attributes     clob;
    v_translations_ref    sys_refcursor;

    v_attr_autocomplete_settings   APEX_APPLICATION_PAGE_ITEMS.attribute_01%type := p_item.attribute_01;
    v_attr_autocomplete_search     APEX_APPLICATION_PAGE_ITEMS.attribute_02%type := p_item.attribute_02;
    v_attr_autocomplete_template   APEX_APPLICATION_PAGE_ITEMS.attribute_03%type := p_item.attribute_03;
    v_attr_autocomplete_d_search   APEX_APPLICATION_PAGE_ITEMS.attribute_04%type := p_item.attribute_04;
    v_attr_settings                APEX_APPLICATION_PAGE_ITEMS.attribute_05%type := p_item.attribute_05;
    v_attr_popup_settings          APEX_APPLICATION_PAGE_ITEMS.attribute_06%type := p_item.attribute_06;
    v_attr_popup_columns_settings  APEX_APPLICATION_PAGE_ITEMS.attribute_07%type := p_item.attribute_07;
    v_attr_autocomplete_tags_no    APEX_APPLICATION_PAGE_ITEMS.attribute_08%type := p_item.attribute_08;
    v_attr_autocomplete_min_length APEX_APPLICATION_PAGE_ITEMS.attribute_09%type := p_item.attribute_09;
    v_attr_popup_report_basic_conf APEX_APPLICATION_PAGE_ITEMS.attribute_10%type := p_item.attribute_10;
    v_attr_popup_title_text        APEX_APPLICATION_PAGE_ITEMS.attribute_11%type := p_item.attribute_11;
    v_attr_popup_width             APEX_APPLICATION_PAGE_ITEMS.attribute_12%type := p_item.attribute_12;
    v_attr_popup_height            APEX_APPLICATION_PAGE_ITEMS.attribute_13%type := p_item.attribute_13;
    v_item_icon_class              APEX_APPLICATION_PAGE_ITEMS.ITEM_ICON_CSS_CLASSES%TYPE ;
    v_apex_version                 APEX_RELEASE.VERSION_NO%TYPE;    
  begin

    g_item := p_item;
    g_plugin := p_plugin;
    g_debug := case when v('DEBUG') = 'YES' then true else false end;
    
    SELECT 
      VERSION_NO 
    into
      v_apex_version
    FROM 
      APEX_RELEASE;

    v_item_name_attr := apex_plugin.get_input_name_for_page_item(
      p_is_multi_value => true
    );

    if g_debug then
      apex_javascript.add_onload_code (
        p_code => 'apex.debug.log("'||v_debug_prefix||'", "p_item", '||t_page_item_to_json(p_item)||');'
      );

      apex_javascript.add_onload_code (
        p_code => 'apex.debug.log("'||v_debug_prefix||'", "p_plugin", '||t_plugin_to_json(p_plugin)||');'
      );

      apex_javascript.add_onload_code (
        p_code => 'apex.debug.log("'||v_debug_prefix||'", "p_params", '||t_item_render_param_to_json(p_param)||');'
      );    
    end if;

    apex_plugin_util.print_hidden_if_readonly (
      p_item_name           => p_item.name,
      p_value               => v_item_value,
      p_is_readonly         => p_param.is_readonly,
      p_is_printer_friendly => p_param.is_printer_friendly
    );
    
    if p_param.is_printer_friendly or p_param.is_readonly then
      apex_plugin_util.print_display_only (
        p_item_name        => p_item.name,
        p_display_value    => f_getDisplayValues(v_item_value),
        p_show_line_breaks => false,
        p_escape           => p_item.escape_output,
        p_attributes       => p_item.element_attributes
      );
    else 
      htp.p(''                                        ||
        '<input'                                      ||
        ' type="text"'                                ||
        ' id="'||p_item.name||'"'                     ||
        ' name="'||v_item_name_attr||'"'              ||
        ' class="text_field apex-item-text '|| p_item.element_css_classes ||'"' ||
        ' maxlength="'||p_item.element_max_length||'"'||
        ' size="'||p_item.element_width||'"'          ||
        ' autocomplete="off"'                         ||
        ' placeholder="'||p_item.placeholder||'"'     ||
        ' value="'                                    ||
      '');

      APEX_PLUGIN_UTIL.PRINT_ESCAPED_VALUE(v_item_value);

      htp.p(''                                        ||
        '"'                                           || --closing of value attr
        ' data-return-value=""'                       ||
        ' '||v_is_required                            ||
        '>'                                           ||
      '');

      --fetch icon
      begin
        select 
          NVL(ITEM_ICON_CSS_CLASSES, v_popup_default_icon)
        into
          v_item_icon_class
        from 
          apex_application_page_items 
        where 
          application_id = g_app_id
          and page_id = g_page_id
          and item_name = p_item.name;
      exception
        when others then
          v_item_icon_class := v_popup_default_icon;
      end;
      
      apex_json.initialize_clob_output;
      apex_json.open_object;
      
      apex_json.write('autoCompleteSettings',             v_attr_autocomplete_settings,   true);
      apex_json.write('autoCompleteSettingsSearchLogic',  v_attr_autocomplete_search,     true);
      apex_json.write('autoCompleteSettingsTemplate',     v_attr_autocomplete_template,   true);
      apex_json.write('autoCompleteTagsNo',               v_attr_autocomplete_tags_no,    true);
      apex_json.write('autoCompleteMinInputLength',       v_attr_autocomplete_min_length, true);
      
      
      apex_json.write('settings',                         NVL(v_attr_settings, ''), true);
      apex_json.write('popupSettings',                    v_attr_popup_settings, true);
      apex_json.write('popupColumnSettings',              v_attr_popup_columns_settings, true);
      apex_json.write('popupReportBasicConf',             v_attr_popup_report_basic_conf, true);
      apex_json.write('popupTitleText',                   v_attr_popup_title_text, true);
      apex_json.write('popupWidth',                       v_attr_popup_width, true);
      apex_json.write('popupHeight',                      v_attr_popup_height, true);
      
      open v_translations_ref for
        select 
          TRANSLATABLE_MESSAGE,
          MESSAGE_TEXT
        from
          APEX_APPLICATION_TRANSLATIONS aat
        where
          APPLICATION_ID = g_app_id
          and LANGUAGE_CODE = (
            select APPLICATION_PRIMARY_LANGUAGE from APEX_APPLICATIONS where application_id = aat.application_id
          )
          and TRANSLATABLE_MESSAGE like 'PAELI%'
      ;

      apex_json.write('translations', v_translations_ref);

      apex_json.close_object;

      v_item_attributes := apex_json.get_clob_output;

      apex_json.free_output;

      apex_javascript.add_onload_code(''                                                                ||
        '$("#' ||v_item_name || '").enhancedLovItem({'                                                  ||
        '  "item":  $.extend('||t_page_item_to_json(p_item)||', {"icon": "'||v_item_icon_class||'"}),'  ||
        '  "param": '||  t_item_render_param_to_json(p_param)||','                                      ||
        '  "plugin": '|| t_plugin_to_json(p_plugin)          ||','                                      ||
        '  "columns": '||f_queryGetColumnsJson||','                                                   ||
        '  "attributes": '||v_item_attributes||','                                                      ||
        '  "apexVersion": "'||v_apex_version||'",'                                                      ||
        '  "debug": "'||v('DEBUG')||'" == "YES" ? true : false '                                        ||
        '});'                                                                                           ||
      '');

    end if;  

  end render;

  --
  -- procedure ajax
  --
  procedure ajax(
    p_item   in            apex_plugin.t_item,
    p_plugin in            apex_plugin.t_plugin,
    p_param  in            apex_plugin.t_item_ajax_param,
    p_result in out nocopy apex_plugin.t_item_ajax_result 
  ) is
    
    v_ajax_mode     varchar2(100)   default v('APP_AJAX_X01');
    v_search_string varchar2(4000)  default v('APP_AJAX_X03');
    v_search_column number          default v('APP_AJAX_X07');
    
  begin

    g_item      := p_item;
    g_plugin    := p_plugin;
    g_debug     := case when v('DEBUG') = 'YES' then true else false end;
    g_ajax_mode := v_ajax_mode;
    g_ajax_search_string := replace(v_search_string, '''', '''''');
    g_ajax_search_column_idx := v('APP_AJAX_X07');

    if g_ajax_mode = 'AUTOCOMPLETE' then
      p_ajax_autocomplete;
    elsif g_ajax_mode = 'POPUP' then
      p_ajax_popup_report;
    elsif g_ajax_mode = 'GETONLYSELECTED' then
      p_ajax_popup_selected;
    elsif g_ajax_mode = 'GETSESSIONSTATE' then
      p_ajax_getSessionState;
    elsif g_ajax_mode = 'DEBUG' then
      null;
    elsif g_ajax_mode = 'CASCADINGLOV' then
      apex_json.open_object;
      apex_json.write( 'request', g_ajax_mode, true );
      apex_json.close_object;  
    else
      p_ajax_getReturnValues;
    end if;

  end ajax;  
end;