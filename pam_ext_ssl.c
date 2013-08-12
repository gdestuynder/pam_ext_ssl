#include <stdio.h>
#include <sys/syslog.h>
#include <security/pam_ext.h>
#include <curl/curl.h>

#define PAM_SM_ACCOUNT
#define PAM_SM_AUTH
#define PAM_SM_PASSWORD
#define PAM_SM_SESSION

#define DEFAULT_SERVER "https://127.0.0.1/"

#ifdef HAVE_SECURITY_PAM_APPL_H
#  include <security/pam_appl.h>
#endif
#ifdef HAVE_SECURITY_PAM_MODULES_H
#  include <security/pam_modules.h>
#endif

int pam_sm_open_session(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return(PAM_IGNORE);
}

int pam_sm_close_session(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return(PAM_IGNORE);
}

int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return(PAM_IGNORE);
}

int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	CURL *curl;
	CURLcode res;
	long response_code = 403;
	int retval;
	const void *user;

	retval = pam_get_item(pamh, PAM_USER, &user);
	if (retval != PAM_SUCCESS || user == NULL || *(const char *)user == '\0')
	{
		pam_syslog(pamh, LOG_NOTICE, "Cannot obtain the user name.");
		return PAM_USER_UNKNOWN;
	}

	curl_global_init(CURL_GLOBAL_DEFAULT);
	curl = curl_easy_init();

	if (!curl) {
		pam_syslog(pamh, LOG_NOTICE, "failed to get a CURL context.");
		return(PAM_ABORT);
	}

	/* get with username here */
	curl_easy_setopt(curl, CURLOPT_URL, DEFAULT_SERVER);
	res = curl_easy_perform(curl);

	if (res != CURLE_OK) {
		pam_syslog(pamh, LOG_NOTICE, "curl_easy_perform() failed: %s",
											curl_easy_strerror(res));
		curl_easy_cleanup(curl);
		return(PAM_ABORT);
	}

	curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);

	curl_global_cleanup();

	if (response_code == 403) {
		pam_syslog(pamh, LOG_NOTICE, "access denied");
		return(PAM_PERM_DENIED);
	}

	pam_syslog(pamh, LOG_NOTICE, "success, code %l", response_code);
	return(PAM_SUCCESS);
}

int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return(PAM_IGNORE);
}

int pam_sm_chauthtok(pam_handle_t *pamh, int flags, int argc, const char **argv) {
	return(PAM_IGNORE);
}
