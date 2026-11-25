# WS101 test log

The following are planned XAMPP integration tests, not claimed passes. Fill in Actual / Result after running them. Use a disposable copy of the new database for destructive tests.

| # | Test / input | Expected | Actual / Result |
|---|---|---|---|
| 1 | Import SQL into a clean MySQL database | Eight related tables and demo records exist | Not run |
| 2 | Correct demo admin credentials | Admin dashboard | Not run |
| 3 | Wrong password | Friendly error, no session | Not run |
| 4 | Teacher credentials with Admin selected | Rejected | Not run |
| 5 | Open protected page signed out | Redirect to login | See build checks below |
| 6 | Student opens `?page=students` or `?page=staff` | HTTP 403 | Not run |
| 7 | Student views Grades | Only own DEMO101 grade | Not run |
| 8 | Student sends grade POST with valid CSRF | HTTP 403; unchanged grades | Not run |
| 9 | Admin sends grade POST with valid CSRF | HTTP 403; unchanged grades | Not run |
| 10 | Teacher sets demo score to 93 | Updated grade visible to student | Not run |
| 11 | Teacher submits enrollment ID 1 (unassigned legacy class) | HTTP 403; unchanged grade | Not run |
| 12 | Teacher enters 101 or -1 | Validation error | Not run |
| 13 | Admin creates/edits/deletes a new unused course | CRUD succeeds | Not run |
| 14 | Admin creates/edits/deletes an unenrolled student | CRUD succeeds | Not run |
| 15 | Duplicate email or course name | Friendly error; valid fields retained | Not run |
| 16 | Delete without confirmation | Rejected | Not run |
| 17 | Delete course with student dependencies | Friendly error; data retained | Not run |
| 18 | Admin issues activation code; student registers | One account linked to intended student | Not run |
| 19 | Reuse activation code | Rejected | Not run |
| 20 | Submit login username `' OR 1=1 --` | Rejected | Not run |
| 21 | POST with absent/incorrect CSRF | HTTP 403 | See build checks below |
| 22 | Enter HTML in student name | Rendered as text, not markup | Not run |
| 23 | Change password and sign in again | Old password rejected, new works | Not run |
| 24 | Admin exports grades | CSV downloads with joined names and scores | Not run |
| 25 | Admin searches nonexistent record | Empty results message | Not run |
| 26 | Stop MySQL then access a DB page | Friendly error, log file updated | Not run |
| 27 | Check `/database/student_management_ws101.sql` and `/logs/error.log` using Apache | 403 forbidden | Not run |
| 28 | Disable a student account while signed in | Next protected request redirects to login | Not run |
| 29 | Teacher removes a demo grade with confirmation | Grade removed; enrollment remains | Not run |

## Build checks

- PASS: all 21 PHP source files passed `php -l`.
- PASS: GET login returns expected 'Sign in' content (protected pages redirect to sign in).
- PASS: GET register returns expected 'Activation code' content (protected pages redirect to sign in).
- PASS: GET dashboard returns expected 'Sign in' content (protected pages redirect to sign in).
- PASS: GET grades returns expected 'Sign in' content (protected pages redirect to sign in).
- PASS: login POST without CSRF token returns HTTP 403.
- NOT RUN: MySQL-backed tests; runtime has no PDO database driver.
