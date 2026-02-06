@IsTest(SeeAllData=true)
public class ReportViewerControllerTest {

    @IsTest
    static void testGetAvailableReports_success() {
        Test.startTest();
        List<ReportDTO> reports = ReportViewerController.getAvailableReports();
        Test.stopTest();

        System.assertNotEquals(null, reports);
    }

    @IsTest
    static void testRunReport_success() {

        Report rpt = [
            SELECT Id
            FROM Report
            WHERE Format = 'TABULAR'
            LIMIT 1
        ];

        Test.startTest();
        system.debug('rpt'+ rpt);
        ReportResultDTO result = ReportViewerController.runReport(rpt.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.columns);
        System.assertNotEquals(null, result.rows);
    }

    @IsTest
    static void testRunReport_exceptionFlow() {
        Test.startTest();
        try {
            // Invalid Report Id to force exception
            ReportViewerController.runReport('00O000000000000AAA');
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            // ✔ Just confirming exception occurred
            System.assert(true);
        }
        Test.stopTest();
    }
}