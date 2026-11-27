# V3 integration checklist (run locally in XAMPP)

All actual browser/database outcomes are **not tested here**. Record actual result and Pass/Fail locally.

| Test | Expected | Actual |
|---|---|---|
| Import upgrade_v3 on V2 | Existing grades, accounts and enrollments preserved | Pending |
| Import upgrade again | No duplicate tables or columns | Pending |
| Import optional demo curriculum | Demo mappings and year levels present | Pending |
| Search student by partial name | Matching student records only | Pending |
| Select student with unknown year | Enrollment unavailable; admin can set year | Pending |
| Select student in year 2 | Year 1 and year 2 selectable, not later years | Pending |
| Select BSIT student | Only mapped BSIT subjects appear | Pending |
| Attempt duplicate enrollment | Blocked both in UI and on server | Pending |
| Submit ineligible subject ID | Rejected; no partial enrollment | Pending |
| Select subject with unmet prerequisite | Disabled and rejected on server | Pending |
| Enroll when prerequisite overall >=75 | Eligible if all other conditions met | Pending |
| Remove ungraded enrollment | Allowed after confirmation | Pending |
| Remove enrollment with period or legacy grade | Rejected | Pending |
| Admin assign fourth class | Rejected | Pending |
| Teacher open assigned class | Roster and period scores visible | Pending |
| Teacher open other teacher's class | 404 / blocked | Pending |
| Teacher search student | Only own assigned classes shown | Pending |
| Enter all five assessment scores | Correct weighted period result | Pending |
| Enter score >100 | Rejected | Pending |
| Record only two periods | Overall pending | Pending |
| Enter 90,85,100 period scores | Overall 91.67 | Pending |
| Delete one period grade | Overall pending; legacy still retained | Pending |
| Student click own grade | Period breakdown displayed | Pending |
| Student request another student's enrollment | 404 / blocked | Pending |
| Student or enrollment staff submit grade POST | 403 | Pending |
| Staff view grades | Read-only period and overall scores | Pending |
| Admin CSV | Period scores, overall, and legacy included | Pending |

Demo weights: exams 40%, quizzes/activities 20%, projects 25%, attendance 10%, participation/other 5%; each period equal weight. Passing mark 75 used only for demo prerequisite decisions. These are not verified HCDC policies.
