global with sharing class OverviewUpdateConfiguration extends nFORCE.ASystemConfigurable {
    public override PageReference configure(){
        PageReference r = Page.OverviewUpdatePage;
        r.setRedirect(true);
        return r;
    }
    public override PageReference back(){
        return Page.LLC_BI__SystemAdministration;
    }
}