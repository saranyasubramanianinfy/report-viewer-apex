public with sharing class ReportViewerController {

    /* =========================
       Public Aura Methods
       ========================= */

    @AuraEnabled(cacheable=true)
    public static List<ReportDTO> getAvailableReports() {
        try {
            List<Report> reports = fetchTabularReports();
            return mapReportsToDTOs(reports);

        } catch (Exception e) {
            AppLogger.error('Error fetching reports', e);
            throw new AuraHandledException('Unable to load reports');
        }
    }

    @AuraEnabled
    public static ReportResultDTO runReport(String reportId) {
        try {
            Reports.ReportResults results =
                Reports.ReportManager.runReport(reportId, true);

            return buildReportResult(results);

        } catch (Exception e) {
            AppLogger.error('Error running report', e);
            throw new AuraHandledException('Failed to execute report');
        }
    }

    /* =========================
       Private Helper Methods
       ========================= */

    private static List<Report> fetchTabularReports() {
        return [
            SELECT Id, Name
            FROM Report
            WHERE Format = 'TABULAR'
            ORDER BY Name
        ];
    }

    private static List<ReportDTO> mapReportsToDTOs(List<Report> reports) {
        List<ReportDTO> results = new List<ReportDTO>();

        for (Report r : reports) {
            results.add(createReportDTO(r));
        }

        System.debug('VALUE ' + reports);
        return results;
    }

    private static ReportDTO createReportDTO(Report report) {
        ReportDTO dto = new ReportDTO();
        dto.reportId = report.Id;
        dto.reportName = report.Name;
        return dto;
    }

    private static ReportResultDTO buildReportResult(
        Reports.ReportResults results
    ) {
        ReportResultDTO response = initializeResultDTO();

        populateColumns(response, results);
        populateRows(response, results);

        AppLogger.info('Report executed successfully');
        return response;
    }

    private static ReportResultDTO initializeResultDTO() {
        ReportResultDTO dto = new ReportResultDTO();
        dto.columns = new List<String>();
        dto.rows = new List<List<String>>();
        return dto;
    }

    private static void populateColumns(
        ReportResultDTO response,
        Reports.ReportResults results
    ) {
        Reports.ReportMetadata meta = results.getReportMetadata();
        Reports.ReportExtendedMetadata extMeta =
            results.getReportExtendedMetadata();

        for (String colKey : meta.getDetailColumns()) {
            response.columns.add(
                extMeta.getDetailColumnInfo()
                    .get(colKey)
                    .getLabel()
            );
        }
    }

    private static void populateRows(
        ReportResultDTO response,
        Reports.ReportResults results
    ) {
        for (Reports.ReportFact fact : results.getFactMap().values()) {

            if (!(fact instanceof Reports.ReportFactWithDetails)) {
                continue;
            }

            Reports.ReportFactWithDetails detailFact =
                (Reports.ReportFactWithDetails) fact;

            for (Reports.ReportDetailRow row : detailFact.getRows()) {
                response.rows.add(extractRowData(row));
            }
        }
    }

    private static List<String> extractRowData(
        Reports.ReportDetailRow row
    ) {
        List<String> rowData = new List<String>();

        for (Reports.ReportDataCell cell : row.getDataCells()) {
            rowData.add(String.valueOf(cell.getValue()));
        }

        return rowData;
    }
}