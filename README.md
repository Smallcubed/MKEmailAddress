# MKEmailAddress
Parse and Represent email addresses using Objective C

Model class for email address and NSScanner extensions to parse a raw email address (RFC2822 compliant  (https://www.ietf.org/rfc/rfc2822.txt) ) into its component parts (label, mailbox, domainName)

The parser will decode MIME encoded email addresses and attempts to handle edge case (ie Non RFC2822 compliant) addresses. (for example raw addresses that contain non-ascii 7 characters)

It can be used to extract email address information, include address comments, from the to:,from:,cc: etc header lines of a compliant email message.


Why NSScanner rather than a NSRegularExpression parsing?

While there are decent enough regular expressions for email address validations, generally they deal with only the user@domain portion of the address and overlook the label.
Not all valid email are easily parseable with a regular expression because of the allowance of comments in specification.
for example `john(Smith("for example"))@sample.host` is a perfectly valid address that should be interpreted as `john@sample.host`

The Scanner approach we think can handle this with more grace.  In doing so, the NSScanner category methods work at scanning the Augmented Backus-Naur Form (ABNF) (https://en.wikipedia.org/wiki/Augmented_Backus%E2%80%93Naur_form)
that specfies an email address (RFC 2822 section 3.4) (for example, scanning for CommentFoldingWhiteSpaces [CFWS]) and quoted text as it works from left to right of the address.

It does not, as of yet scan for groups.

Additionally, the parse will decode MIME Encoded Words found in a display-name of an address when parsing.


