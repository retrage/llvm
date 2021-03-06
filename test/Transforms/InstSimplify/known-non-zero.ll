; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

define i64 @test0(i64 %x) {
; CHECK-LABEL: @test0(
; CHECK-NEXT:  start:
; CHECK-NEXT:    [[A:%.*]] = icmp eq i64 [[X:%.*]], 0
; CHECK-NEXT:    br i1 [[A]], label [[EXIT:%.*]], label [[NON_ZERO:%.*]]
; CHECK:       non_zero:
; CHECK-NEXT:    [[B:%.*]] = icmp eq i64 [[X]], 0
; CHECK-NEXT:    br i1 [[B]], label [[UNREACHABLE:%.*]], label [[EXIT]]
; CHECK:       unreachable:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[C:%.*]] = phi i64 [ 0, [[START:%.*]] ], [ 1, [[NON_ZERO]] ], [ 2, [[UNREACHABLE]] ]
; CHECK-NEXT:    ret i64 [[C]]
;
start:
  %a = icmp eq i64 %x, 0
  br i1 %a, label %exit, label %non_zero

non_zero:
  %b = icmp eq i64 %x, 0
  br i1 %b, label %unreachable, label %exit

unreachable:
  br label %exit

exit:
  %c = phi i64 [ 0, %start ], [ 1, %non_zero ], [ 2, %unreachable ]
  ret i64 %c
}

define i64 @test1(i64 %x) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  start:
; CHECK-NEXT:    [[A:%.*]] = icmp eq i64 [[X:%.*]], 0
; CHECK-NEXT:    br i1 [[A]], label [[EXIT:%.*]], label [[NON_ZERO:%.*]]
; CHECK:       non_zero:
; CHECK-NEXT:    [[B:%.*]] = icmp ugt i64 [[X]], 0
; CHECK-NEXT:    br i1 [[B]], label [[EXIT]], label [[UNREACHABLE:%.*]]
; CHECK:       unreachable:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[C:%.*]] = phi i64 [ 0, [[START:%.*]] ], [ [[X]], [[NON_ZERO]] ], [ 0, [[UNREACHABLE]] ]
; CHECK-NEXT:    ret i64 [[C]]
;
start:
  %a = icmp eq i64 %x, 0
  br i1 %a, label %exit, label %non_zero

non_zero:
  %b = icmp ugt i64 %x, 0
  br i1 %b, label %exit, label %unreachable

unreachable:
  br label %exit

exit:
  %c = phi i64 [ 0, %start ], [ %x, %non_zero ], [ 0, %unreachable ]
  ret i64 %c
}

define i1 @test2(i64 %x, i1 %y) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  start:
; CHECK-NEXT:    [[A:%.*]] = icmp eq i64 [[X:%.*]], 0
; CHECK-NEXT:    br i1 [[A]], label [[EXIT:%.*]], label [[NON_ZERO:%.*]]
; CHECK:       non_zero:
; CHECK-NEXT:    br i1 [[Y:%.*]], label [[ONE:%.*]], label [[TWO:%.*]]
; CHECK:       one:
; CHECK-NEXT:    br label [[MAINBLOCK:%.*]]
; CHECK:       two:
; CHECK-NEXT:    br label [[MAINBLOCK]]
; CHECK:       mainblock:
; CHECK-NEXT:    [[P:%.*]] = phi i64 [ [[X]], [[ONE]] ], [ 42, [[TWO]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[P]], 0
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[RES:%.*]] = phi i1 [ [[CMP]], [[MAINBLOCK]] ], [ true, [[START:%.*]] ]
; CHECK-NEXT:    ret i1 [[RES]]
;
start:
  %a = icmp eq i64 %x, 0
  br i1 %a, label %exit, label %non_zero

non_zero:
  br i1 %y, label %one, label %two

one:
  br label %mainblock

two:
  br label %mainblock

mainblock:
  %p = phi i64 [ %x, %one ], [ 42, %two ]
  %cmp = icmp eq i64 %p, 0
  br label %exit

exit:
  %res = phi i1 [ %cmp, %mainblock ], [ 1, %start ]
  ret i1 %res
}
