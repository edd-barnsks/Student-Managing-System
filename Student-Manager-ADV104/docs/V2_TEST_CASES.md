# V2 test cases

Run against a local XAMPP backup/test database. Record actual result and pass/fail for each. Only the isolated calculation, forbidden-POST checks and static checks were run in the build environment; database-backed tests remain pending.

| Test | Expected result |
|---|---|
| Upgrade existing database | Prior users, enrollments, final grades remain unchanged; five columns and staff enum added |
| Re-import upgrade | No duplicate-column errors; old scores remain unchanged |
| Fresh schema import | All eight tables created with new columns and role |
| Import previous HCDC sample data | Legacy sample grades remain valid with NULL components |
| Admin creates enrollment staff | New role can log in; teacher/admin login options cannot be used for that account |
| Staff opens student directory and class catalog | Read-only records; no create/edit/delete controls |
| Staff enrolls student into two classes | Two enrollments saved and visible to student/assigned teachers |
| Staff repeats enrollment | Existing links skipped, no duplicate records |
| Staff chooses invalid class in batch | Entire transaction rolls back |
| Staff removes ungraded enrollment with confirmation | Removed, audit logged |
| Staff attempts removal of graded enrollment | Rejected; grade and enrollment preserved |
| Staff views grades | Final grades visible, no calculator/edit/delete buttons |
| Staff sends forged POST to grades | HTTP 403; no data modification |
| Staff opens admin staff/accounts/course/audit/export routes | HTTP 403 |
| Staff sends forged POST to students/classes | HTTP 403 |
| Teacher enters 90, 85, 95, 100, 80 | Preview and stored grade 90.75 |
| Teacher enters all 0 or all 100 | 0.00 or 100.00 stored |
| Teacher enters blank, -1, 101, or 90.123 | Validation error; no record changed |
| Teacher submits a fake final score | Ignored; score computed server-side |
| Teacher reloads existing breakdown | All saved category values shown |
| Teacher opens another teacher's enrollment | Not found or access denied |
| Teacher submits another teacher's enrollment | Rejected; no write |
| Student opens own grade list | Own grades and component details only |
| Student or admin attempts grade write | HTTP 403 |
| Admin exports CSV | Component scores and final score columns included |
| Legacy grade viewed | Old final remains; components show dash, not zero |
| Teacher updates legacy grade | Complete real component percentages required |
| Staff changes own password | Session invalidated; new password works |

The 40/20/25/10/5 policy is illustrative, not an official HCDC grading formula. Validate the school policy before using real student records.
