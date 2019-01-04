/**
 * Scheduled Apex to run BatchSetExcludeFromExposureCalc
 *
 * @author  Chintan Adhyapak, West Monroe Partners
 * @created 01/03/2018
 */
global class ScheduleBatchSetExcludeFromExposureCalc implements Schedulable {
    global void execute(SchedulableContext sc) {
		BatchSetExcludeFromExposureCalc batchJob = new BatchSetExcludeFromExposureCalc();
        Database.executeBatch(batchJob);
	} //execute
} //ScheduleBatchSetExcludeFromExposureCalc