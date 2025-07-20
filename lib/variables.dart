const VersionType currentVersionType = VersionType.dev;
const String githubRepoUrl = 'https://github.com/TrongAJTT/SETPocket';
const String appName = 'SETPocket';
const String githubIssuesUrl = '';
const String githubContributorsUrl = '';
const String githubSponsorUrl = '';
const String githubReleaseUrl = '';
const String paypalDonateUrl = '';
const String donateKofiUrl = '';

const double tabletScreenWidthThreshold = 600.0;
const double desktopScreenWidthThreshold = 1024.0;

const int p2pChatMediaWaitTimeBeforeDelete = 6; // seconds
const int p2pChatClipboardPollingInterval = 3; // seconds

// This enum represents the different types of app versions.
// It is used to determine the current version type of the application.
enum VersionType {
  release,
  beta,
  dev,
}
