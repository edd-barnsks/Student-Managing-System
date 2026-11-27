# V4 local integration test checklist

Record actual result and pass/fail after testing in XAMPP. All cases below are pending live verification.

| ID | Test | Expected result |
|---|---|---|
| 1 | Export V3 backup, import upgrade | Existing row counts and prior grades unchanged; two new tables, new columns and view available |
| 2 | Reimport upgrade | No duplicate academic terms or columns; existing values retained |
| 3 | Create AY 2026-2027, first semester | Term selectable in Classes |
| 4 | Create invalid year 2026-2029 | Friendly validation error |
| 5 | Create class with 3 units | Units, term and teacher saved |
| 6 | Try 0 units or >12 units | Rejected |
| 7 | Same subject code twice in one term | Duplicate rejected |
| 8 | Same code in a different term | Separate offering created |
| 9 | Assign fourth subject to a teacher in one term | Rejected; different term has separate limit |
| 10 | Teacher Classes on desktop and narrow screen | Responsive separated cards; visible title, units, schedule, roster link |
| 11 | Filter teacher Classes by term and open roster | Only matching assigned subjects and students |
| 12 | Teacher guesses another class or enrollment ID | Access denied or not found |
| 13 | Staff searches student and selects term | Eligible subjects for selected course/year and offered term only |
| 14 | Try previously passed or already enrolled subject | Rejected |
| 15 | Try a subject with unmet prerequisite | Rejected |
| 16 | Attempt forged enrollment in wrong term | Rejected server-side |
| 17 | Enter exams 45/50, 80/100 | Category 83.33% |
| 18 | Enter quizzes 8/10, 18/20 | Category 86.67% |
| 19 | Projects 90, attendance 100, participation 90 with above | Period grade 87.67; JS preview matches saved PHP result |
| 20 | Earned greater than max or max zero | Rejected |
| 21 | Save draft then reload | Individual marks and calculated grade retained |
| 22 | Submit draft after confirmation | Period locked, no editor shown |
| 23 | Forge save/delete POST for locked grade | No score or assessment changes |
| 24 | Staff or student forges grade POST | Access denied |
| 25 | Admin tries score save | Access denied |
| 26 | Admin reopens locked period with reason | Unlock audited, teacher can edit |
| 27 | Student clicks subject grade | Only own record; period breakdown, individual marks, draft/lock status |
| 28 | Student changes detail URL to another student | Not found |
| 29 | Staff opens grade detail URL | Access denied; summary remains viewable |
| 30 | Student term filter and unit-weighted average | Only matching term grades; known completed units used with coverage |
| 31 | Export grades CSV | Term, units and locked count included |
| 32 | Existing V3 grades without raw assessment rows | Historical marks remain intact, no invented raw marks |
| 33 | Try deleting enrollment with a submitted period | Rejected |
| 34 | Verify logs and audit entries | Submission and reopening actor/reason present; errors not displayed raw |
