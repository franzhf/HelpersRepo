
BEGIN --DATA OBJECT 
	/*
	 *  Select columns by dataobject name or column name
	 *  TODO:
	 *		- 
	 */
	declare @table_name nvarchar(50) = 'individual' --put % ....% if you dont want search by complete name
	declare @column_name varchar(50) = '%bax_bat_key%'
	declare @byColName bit = 0 -- set 0 for searching by table name
	declare @objectKey av_key = '1a83491a-9853-4c87-86a4-f7d95601c2e2'


	select mdc_description [DESCRIPTION], 
		   mdc_name [NAME],
		   mdc_key,
		   mdc_table_name [TABLE NAME],
		   mdc_control_class,
		   mdc_value_from,
		   mdc_value_column,	   
		   mdc_data_type, 
		   mdc_nullable, 
		   mdc_readonly, *
	from md_column _column (nolock)
	where (@byColName = 0 and mdc_mdt_name like @table_name)  --by table
	or (mdc_name like @column_name and @byColName = 1) -- by column
	order by mdc_name, mdc_description

	select * from md_object
	where obj_key = @objectKey	OR  @table_name = obj_name
END
GO

BEGIN --WIZARD
	/*
	 * Gets information about wizard
	 * TO DO:
	 *		 - 
	 */
	declare @wizardKey av_key = 'cbd14872-80c4-40a9-a8a9-74a37c3a7db2'

	select top 10 * from md_wizard
	where wiz_key = @wizardKey

	-- wizard forms of the current wizard
	SELECT wzf_key, *  FROM md_wizard_form  WITH (NOLOCK)  WHERE wzf_wiz_key = @wizardKey ORDER BY wzf_order ASC

	--wizard form which has a child form
	select wiz_description [wizard description], wzf_form_title, * from md_wizard_form (nolock)
	join md_wizard (nolock) on wiz_key = wzf_wiz_key
	where wzf_dyc_key is not null
	order by wiz_description desc
END
GO

BEGIN -- TABLE
	declare @prefix varchar(3) = 'mox'
	select * from md_table
	where mdt_prefix = @prefix
END
GO

BEGIN -- SERIALIZE OBJECT TABLE
	declare @customerKey av_key = '0d5028a0-3e81-45a4-a001-5e31886fe1c8'
	select top 10 * from md_order_entry_serialize (nolock)
	join md_object_xml_serialize (nolock) on oex_mox_key = mox_key
	--where oex_cst_key = @customerKey
	order by oex_add_date desc
END
GO

select  * from cm_group_item
where cgi_code like 'gateway%'
and cgi_cgr_key = 'E54C896B-0BFB-4680-AC6F-11FF9AD33B53'


exec sp_columns 'ce_individual_desig'



/*
 * 
 */
SELECT COLUMN_NAME, TABLE_NAME, * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE 'arp_key%'

/*
 * Find a table
 */	

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'co_call2action_detail%'
ORDER BY 4

select top 100 * from vw_collective_dues_open_liability
order by vli_ixo_start_date desc
/*
 * Know relationships between all the tables of database in SQL Server
 * Sometimes, a textual representation might also help; with this query on the system catalog views, you can get a list of all FK relationships and how the link two tables (and what columns they operate on).
 * 
 */
SELECT
    fk.name 'FK Name',
    tp.name 'Parent table',
    cp.name, cp.column_id,
    tr.name 'Referenced table',
    cr.name, cr.column_id
FROM 
    sys.foreign_keys fk
INNER JOIN 
    sys.tables tp ON fk.parent_object_id = tp.object_id
INNER JOIN 
    sys.tables tr ON fk.referenced_object_id = tr.object_id
INNER JOIN 
    sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN 
    sys.columns cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
INNER JOIN 
    sys.columns cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
	where tp.name like '%ts_scheduled_task%'
ORDER BY
    tp.name, cp.column_id



	/*
	 *
	 */

exec md_where_used 'Application_Error'

select [mdc_name], * FROM md_column (nolock) WHERE mdc_key='2996FE17-26EB-47C2-9821-75FBC825C5BC'

/**
 * Form Link
 *
 */  

 select mfl_link_sql_where, * from md_form_link
 where mfl_link_sql_where is not null
 and mfl_link_sql_where like '%from%'


 /*
  *  Data object
  *
  */

    select obd_key_field, obd_parent_key, * from md_object_data

/**
 *  Show all controls that contains a particular form
 */

 SELECT dyn_key, dys_key, dyn_description, dys_control_name, dys_control_class FROM md_dynamic_form
 JOIN md_dynamic_form_control (NOLOCK) ON dys_dyn_key = dyn_key
 WHERE dyn_key = 'a60a4a6d-6ae1-4c1d-a008-09b6efc1f4b4'
 order by dys_control_name desc


 DELETE md_dynamic_form_control WHERE dys_dyn_key = '9f6c657e-01d0-4749-9118-078d04567ce3' AND dys_control_name = 'TEXT_0'

 select * from md_dynamic_form_control

 /**
  * Get the key of a specific control
  *
  */

  SELECT dys_key FROM [dbo].[md_dynamic_form_control] 
  WHERE [dys_control_name]=N'mls_name' AND [dys_dyn_key]='9f6c657e-01d0-4749-9118-078d04567ce3'

  /**
    * Review child forms / find child form by SQL content and grid title
	*/

	select dyc_sql, dyc_dyn_key, dyc_grid_title [GRID TITLE], dyn_title [FORM TITLE], cgr_code [MODULE], items.cgi_code [GROUP ITEM]
	from md_dynamic_form_child
	join md_dynamic_form on dyn_key = dyc_dyn_key
	join cm_group_item_link on  cgl_dynamic_form = dyn_key
	join cm_group_item items on cgl_cgi_key = cgi_key
	join cm_group on cgi_cgr_key = cgr_key
	where dyc_sql like '%status%' and dyc_sql like '%duration%'
	where dyc_grid_title like '%history%'
	/*
	 * Show all child forms of a particular FORM
	 */

	 select * from md_dynamic_form_child
	 where dyc_dyn_key = '26fdf0f8-69b0-43d5-a4ec-32eefdc1bff9'

	 select top 100 * from ws_activity_log with (nolock)
	 where xwl_add_date between '2014-08-12' and '2014-08-26'
	 and xwl_add_user = '%asmith%'

	select top 10  * from md_dynamic_form
	where dyn_description like '%edit%'
	order by dyn_add_date desc



	/**/
	 select top 10 *  from md_column
	 where mdc_name = 'vos_ods_balance'

	 /* Get all columns by table*/

	 select top 10 *  from md_column
	 where 
	 --mdc_description like '%initial%'
	 mdc_mdt_name = 'md_dynamic_form_extension'


	 /**/

	 EXEC sp_helpsrvrolemember 'sysadmin'


	 select top 100 * from md_web_content_detail
	 where wbd_content_type like 'html' and wbd_html like '%{%' and wbd_html like '%SCRIPT%' and wbd_html like '%document%'
	 sre_key is null 


	 /*DELETE A COLUMN FROM A TABLE*/

	 /*Based*/
SET ANSI_NULLS ON

GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from sys.objects where [name] = N'FK_co_questionnaire_reviewer_x_response_header' and [type] = 'F')
ALTER TABLE [dbo].[co_questionnaire_disclosure_review] DROP CONSTRAINT [FK_co_questionnaire_reviewer_x_response_header]
GO
ALTER TABLE [dbo].[co_questionnaire_disclosure_review]
	DROP COLUMN [qdr_qra_key]
GO


begin transaction
/*drop sre_sss_key */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from sys.objects where [name] = N'FK_co_survey_response_header_co_survey_response_status' and [type] = 'F')
ALTER TABLE [dbo].[co_survey_response_header] DROP CONSTRAINT [FK_co_survey_response_header_co_survey_response_status]
GO
IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'sre_sss_key' AND [object_id] = OBJECT_ID(N'co_survey_response_header'))
ALTER TABLE [dbo].[co_survey_response_header]
	DROP COLUMN [sre_sss_key]
GO

/*
 * Get the FK created for a table
 */

select * from sys.objects where [name] like N'%FK_co_survey_response_header_co_survey_response_status%' and [type] = 'F'


select top 10 dyc_dyn_key, dyc_key, * from md_dynamic_form_child
where  dyc_key in ('A8406674-20B7-4DA4-95E0-73A15CBA7A03', '3BC8B161-67C1-4B1B-B982-BA78D8F15B88')


/*
 * Script 
 */

 select 
fsc_key,
fsc_desc as [bug/issue],
fsc_add_date as [add date],
fsc_add_user as [add user],
fsc_script
from
md_service_pack_script (nolock)
where
fsc_delete_flag=0
and fsc_script like '%fax%'
and fsc_add_user like '%ealvarez%'
order by
fsc_add_date desc


/*view where a dynamic form is used , group item, group */
--BEGIN
select * 
from cm_group_item GroupItem (nolock)
join cm_group _Group (nolock) on cgi_cgr_key = cgr_key --parent
join cm_group_item_link GroupItemLink (nolock) on cgl_cgi_key = cgi_key
join md_dynamic_form (nolock) on cgl_dynamic_form = dyn_key
where dyn_key like 'E54C896B-0BFB-4680-AC6F-11FF9AD33B53'
and cgi_cgr_key = 'E54C896B-0BFB-4680-AC6F-11FF9AD33B53'
-- navigate in netforum , review the refence tab in the profile page
--END


/* Get a child form by table name using the sql child form content*/

select top 10 dyc_sql, dyc_dyn_key, dyc_description,  form.* 
from md_dynamic_form_child  formChild(NOLOCK)
join md_dynamic_form form (NOLOCK) on dyn_key = dyc_dyn_key
where dyc_sql like '%ad_insertion_order_detail%'

/*gets an extension by the object name*/

select top 10 dyx_object_typename, * from md_dynamic_form_extension (nolock)
where dyx_object_typename like '%apply%'

select top 10 * from md_dynamic_form_extension (nolock)
where dyx_object_initialize_method like '%Application_Error%' or
      dyx_object_load_method       = '%Application_Error%' or
	  dyx_object_execute_method    = '%Application_Error%' or



select rcp_key, prd_name as [Publication], ptp_code as [Type] 
from ad_rate_card_x_publication (nolock)      
	join oe_product (nolock)      on rcp_prd_key=prd_key join oe_product_type (nolock)      on ptp_key=prd_ptp_key
where rcp_arc_prd_key={arc_prd_key} and prd_delete_flag = 0
order by 2,3  


/*Review dynamic form control*/
select dys_data, dys_control_name, dys_control_class from md_dynamic_form_control
where dys_data is not null
and dys_data like '%always%'
order by dys_control_name 


/*temporal table*/

Declare @test table
(
	decimal_ decimal (10,2)
)

select * from @test

insert into @test (decimal_) select 1
insert into @test (decimal_) select 1.5
insert into @test (decimal_) select 3.5
insert into @test (decimal_) select 0.01

update @test
set decimal_ = '0.01'



