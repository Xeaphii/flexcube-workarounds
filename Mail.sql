/* Formatted on 4/27/2016 11:25:22 AM (QP5 v5.227.12220.39724) */
DECLARE
   v_From               VARCHAR2 (80) := 'oracle@mycompany.com';
   v_Recipient          VARCHAR2 (80) := 'zeeshan.karamat@techlogix.com';
   v_Subject            VARCHAR2 (80) := 'test subject';
   v_Mail_Host          VARCHAR2 (30) := '119.30.86.103';
   v_Mail_Conn          UTL_SMTP.Connection;
   crlf                 VARCHAR2 (2) := CHR (13) || CHR (10);
   pending_trn_number   NUMBER;
BEGIN
   SELECT SUM (difference)
     INTO pending_trn_number
     FROM (SELECT NVL (
                     SUM (
                        DECODE (drcr_ind, 'C', lcy_amount, -1 * lcy_amount)),
                     0)
                     difference
             FROM flexcube3.actb_daily_log
            WHERE     ac_branch = '101'
                  AND auth_stat <> 'U'
                  AND NVL (delete_stat, 'X') <> 'D'
                  AND category IN ('1', '2', '3', '4')
           UNION ALL
           SELECT NVL (
                     SUM (
                        DECODE (drcr_ind, 'C', lcy_amount, -1 * lcy_amount)),
                     0)
                     difference
             FROM flexcube3.actb_daily_log
            WHERE     ac_branch = '101'
                  AND auth_stat <> 'U'
                  AND NVL (delete_stat, 'X') <> 'D'
                  AND category IN ('5', '6')
           UNION ALL
           SELECT NVL (
                     SUM (
                        DECODE (drcr_ind, 'C', lcy_amount, -1 * lcy_amount)),
                     0)
                     difference
             FROM flexcube3.actb_daily_log
            WHERE     ac_branch = '101'
                  AND auth_stat <> 'U'
                  AND NVL (delete_stat, 'X') <> 'D'
                  AND category IN ('8', '9'));

   IF pending_trn_number >= 0
   THEN
      v_Mail_Conn := UTL_SMTP.Open_Connection (v_Mail_Host, 25);
      UTL_SMTP.Helo (v_Mail_Conn, v_Mail_Host);
      UTL_SMTP.Mail (v_Mail_Conn, v_From);
      UTL_SMTP.Rcpt (v_Mail_Conn, v_Recipient);
      UTL_SMTP.Data (
         v_Mail_Conn,
            'Date: '
         || TO_CHAR (SYSDATE, 'Dy, DD Mon YYYY hh24:mi:ss')
         || crlf
         || 'From: '
         || v_From
         || crlf
         || 'Subject: '
         || v_Subject
         || crlf
         || 'To: '
         || v_Recipient
         || crlf
         || crlf
         || 'Branch is out. Kindly take some action'
         || crlf
         || crlf);
      UTL_SMTP.Quit (v_mail_conn);
   END IF;
EXCEPTION
   WHEN UTL_SMTP.Transient_Error OR UTL_SMTP.Permanent_Error
   THEN
      raise_application_error (-20000, 'Unable to send mail', TRUE);
END;
/