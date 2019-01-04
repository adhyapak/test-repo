public with sharing class csaHmdaExtractGenerationController {

    public class RunGeneration extends nFORCE.RemoteActionController.Endpoint {
        public override virtual Object invoke(Map<String,Object> params) {
            DateTime sd = DateTime.newInstance(
                long.valueOf((String)params.get(csaHmdaExtractConstants.STARTDATE))
            );
            DateTime ed = DateTime.newInstance(
                long.valueOf((String)params.get(csaHmdaExtractConstants.ENDDATE))
            );

            Id jobId = System.enqueueJob(new csaHmdaExtractGenerationJob(
                UserInfo.getUserEmail(), UserInfo.getName(),
                Date.newinstance(sd.year(), sd.month(), sd.day()),
                Date.newinstance(ed.year(), ed.month(), ed.day())
            ));

            return null;
        }
    }
}