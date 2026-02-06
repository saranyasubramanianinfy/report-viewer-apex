public class AppLogger {
    public static void info(String message) {
        System.debug(LoggingLevel.INFO, message);
    }

    public static void error(String message, Exception e) {
        System.debug(LoggingLevel.ERROR, message + ' | ' + e.getMessage());
    }
}