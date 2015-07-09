


/*
 * Select all child form which have override links
 *
 */

BEGIN
 /*
  *
  */
  select top 10 * from md_table
  where mdt_prefix = 'pay'
END


BEGIN
	/*
	 * selects batch(es) by the batch code or key
	 * @displayAll = 0  selects all batches which are closed and posted, = 1 selects all batches(but only when is not defined a batch code or key)
	 *  
	 */
	declare @displayAll bit = 1
	declare @batchCode varchar(50) = '' -- bat_code
	declare @batchKey av_key = '00000000-0000-0000-0000-000000000000'  -- bat_key


	declare @searchByCodOrKey bit = 0
	if(@batchCode != '' or @batchKey != '00000000-0000-0000-0000-000000000000')
		select @searchByCodOrKey = 1

	select distinct bat_key, 
		   bat_code [BAT CODE],  
		   bat_close_date [CLOSE DATE],
		   bat_close_user [CLOSE USER],
		   bat_close_flag [CLOSE FLAG],
		   bat_post_date [POSTED DATE],
		   bat_post_user [POSTED USER],
		   bat_post_flag [POST FLAG],		 
		   bat_control_trx_count [CONTROL TOTAL COUNT],
		   bat_control_total [CONTROL TOTAL AMOUNT],		   
		   bat_add_date [BATCH ADD DATE],
		   bat_add_user [BATCH ADD USER],
		   bat_lock_flag [ LOCK FLAG],
		   		   
		   bat_file,
		   MiscTransaction.mis_post_flag,
		   MiscTransaction.mis_bat_close_flag,
		   --ledger.led_gla_code [GL ACCOUNT],
		   --led_bat_date [LED BATCH DATE],
		   --led_trx_date [LED TRANSACTION DATE],
		   --led_trx_type [LED TRANSACTION TYPE],
		   BatchExport.bax_key,
		   BatchExport.bax_key,
		   BatchExport.*
	from ac_batch batch (nolock)
	left join ac_misc_transaction MiscTransaction on MiscTransaction.mis_bat_key = batch.bat_key --Miscellaneous Transaction.
	left join ac_misc_transaction_detail MiscTransactionDetail on MiscTransactionDetail.mid_mis_key = MiscTransaction.mis_key  --Miscellaneous Transaction Detail.
	--left join ac_ledger ledger on ledger.led_bat_key = batch.bat_key
	left join ac_batch_export BatchExport on BatchExport.bax_bat_key = batch.bat_key
	where (bat_code like @batchCode or bat_key = @batchKey and @searchByCodOrKey = 1) -- by bacth code or key
	       or (batch.bat_close_date is not null and batch.bat_post_date is not null and @displayAll = 0 and @searchByCodOrKey = 0)   -- only bacthes that are closed and posted
	       or (@displayAll = 1 and @searchByCodOrKey = 0) -- all bacthes

	order by bat_add_date/*, bat_close_date*/ desc

	if(@batchCode!= '')
		select * from ac_batch_export BatchExport
		join ac_batch batch on BatchExport.bax_bat_key = batch.bat_key
		where bat_code = @batchCode

END
GO

BEGIN
	/*
	 * Re-open batch(es) by the batch code , 
	 * 1. nullify the columns [bat_close_date, bat_post_date, bat_close_user, bat_post_user, bat_control_total, bat_control_trx_count]
	 * 1. set bat_control_total and bat_control_trx_count to 0
	 * 2. set trd_posted to 0
	 * 3. hard delete corresponding ac_ledger records   Note: system creates ac_ledger records when user closes a batch.
	 */ 
	 declare @batchCode1 varchar(50) = '2012-02-01-DLDBU-001' -- bat_code
	 declare @batchCode2 varchar(50) = 'xxxxxxxx' -- bat_code
	 declare @batchCode3 varchar(50) = 'xxxxxxxx' -- bat_code
	/* 1. */
	update ac_batch set
	
		bat_close_date = null,
		bat_post_date = null,
		--bat_usr_key = null,
		bat_close_user = null,
		bat_post_user = null,
		bat_control_total = 0.00,
		bat_control_trx_count = 0,
		bat_close_flag = 0,
		bat_post_flag = 0
	from ac_batch batch(nolock)
	where batch.bat_code in (@batchCode1, @batchCode2, @batchCode3) --(Live)
	and bat_close_flag = 1 and bat_post_flag = 1
	/* 2. */
	update ac_misc_transaction set
		mis_post_flag = 0,
		mis_bat_close_flag = 0
	from ac_batch batch (nolock)
	join ac_misc_transaction MiscTransaction on MiscTransaction.mis_bat_key = batch.bat_key --Miscellaneous Transaction.
	where bat_code in (@batchCode1, @batchCode2, @batchCode3)
	and mis_post_flag = 1 
	and mis_bat_close_flag = 1

	/* 3. */
	delete from ac_ledger 
	where led_bat_key in (select bat_key from ac_batch batch (nolock)
						  join ac_misc_transaction MiscTransaction on MiscTransaction.mis_bat_key = batch.bat_key --Miscellaneous Transaction.
						  where batch.bat_code in (@batchCode1, @batchCode2, @batchCode3)) 

END
GO


/*  9:16:26 PM */ select top 1 * from ac_invoice where inv_bat_key = 'bd60f537-aa4c-4629-b345-b616cd300321' /* -~.Extension.BatchProcessTaskExtension.ExecuteBatchAction - ~.Extension.BatchProcessTaskExtension.CreateSummaryReport - ~AC.Batch.Close - ~Account.Batch.BatchProcess.Close - ~Account.Batch.BatchProcess.ProcessBatch - ~Account.Batch.TransactionAnalysis..ctor - ~Account.Batch.TransactionAnalysis.RunAnalysis - ~Account.Batch.TransactionAnalysis.ContainsRecords - ~DataUtils.DataExistsInSQL - ~DataUtils.GetDataReader - ~DataUtils.GetDataReader -  */ 
/*  9:16:31 PM */ select top 1 * from ac_payment where pay_bat_key = 'bd60f537-aa4c-4629-b345-b616cd300321' /* -~.Extension.BatchProcessTaskExtension.ExecuteBatchAction - ~.Extension.BatchProcessTaskExtension.CreateSummaryReport - ~AC.Batch.Close - ~Account.Batch.BatchProcess.Close - ~Account.Batch.BatchProcess.ProcessBatch - ~Account.Batch.TransactionAnalysis..ctor - ~Account.Batch.TransactionAnalysis.RunAnalysis - ~Account.Batch.TransactionAnalysis.ContainsRecords - ~DataUtils.DataExistsInSQL - ~DataUtils.GetDataReader - ~DataUtils.GetDataReader -  */ 
/*  9:16:37 PM */ select top 1 * from ac_credit where cdt_bat_key = 'bd60f537-aa4c-4629-b345-b616cd300321' /* -~.Extension.BatchProcessTaskExtension.ExecuteBatchAction - ~.Extension.BatchProcessTaskExtension.CreateSummaryReport - ~AC.Batch.Close - ~Account.Batch.BatchProcess.Close - ~Account.Batch.BatchProcess.ProcessBatch - ~Account.Batch.TransactionAnalysis..ctor - ~Account.Batch.TransactionAnalysis.RunAnalysis - ~Account.Batch.TransactionAnalysis.ContainsRecords - ~DataUtils.DataExistsInSQL - ~DataUtils.GetDataReader - ~DataUtils.GetDataReader -  */ 
/*  9:16:40 PM */ select top 1 * from ac_refund where ref_bat_key = 'bd60f537-aa4c-4629-b345-b616cd300321' /* -~.Extension.BatchProcessTaskExtension.ExecuteBatchAction - ~.Extension.BatchProcessTaskExtension.CreateSummaryReport - ~AC.Batch.Close - ~Account.Batch.BatchProcess.Close - ~Account.Batch.BatchProcess.ProcessBatch - ~Account.Batch.TransactionAnalysis..ctor - ~Account.Batch.TransactionAnalysis.RunAnalysis - ~Account.Batch.TransactionAnalysis.ContainsRecords - ~DataUtils.DataExistsInSQL - ~DataUtils.GetDataReader - ~DataUtils.GetDataReader -  */ 
/*  9:16:43 PM */ select top 1 * from ac_adjustment where adj_bat_key = 'bd60f537-aa4c-4629-b345-b616cd300321' /* -~.Extension.BatchProcessTaskExtension.ExecuteBatchAction - ~.Extension.BatchProcessTaskExtension.CreateSummaryReport - ~AC.Batch.Close - ~Account.Batch.BatchProcess.Close - ~Account.Batch.BatchProcess.ProcessBatch - ~Account.Batch.TransactionAnalysis..ctor - ~Account.Batch.TransactionAnalysis.RunAnalysis - ~Account.Batch.TransactionAnalysis.ContainsRecords - ~DataUtils.DataExistsInSQL - ~DataUtils.GetDataReader - ~DataUtils.GetDataReader -  */ 
/*  9:16:46 PM */ select top 1 * from ac_misc_transaction where mis_bat_key = 'bd60f537-aa4c-4629-b345-b616cd300321' /* -~.Extension.BatchProcessTaskExtension.ExecuteBatchAction - ~.Extension.BatchProcessTaskExtension.CreateSummaryReport - ~AC.Batch.Close - ~Account.Batch.BatchProcess.Close - ~Account.Batch.BatchProcess.ProcessBatch - ~Account.Batch.TransactionAnalysis..ctor - ~Account.Batch.TransactionAnalysis.RunAnalysis - ~Account.Batch.TransactionAnalysis.ContainsRecords - ~DataUtils.DataExistsInSQL - ~DataUtils.GetDataReader - ~DataUtils.GetDataReader -  */ 


