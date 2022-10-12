program main
    integer::i
    integer::array(5),arrayb(5),array3(3,2)
    character *70:: str
    real::nan,a,b
    array=(/1,2,3,4,5/)
    array3=reshape((/1,2,3,4,5,6/),(/3,2/))
    write(*,*)'min=', maxval(array3(:,1))
    arrayb=array
    arrayb(2)=10
    call change(array)
    do i=1,5,1
        if(i==3)cycle
        write(*,*)array(i),arrayb(i)
    end do
    ! read(*,*)nan
    ! write(*,*)nan
    ! if (isnan(nan)) then
    !  write(*,*)'ok'
    !  end if 
    ! write(*,*)atan(-1.)
    write(*,*)1.*2.3,1*2.3
    a=1.
    b=34.9
    if (a-b<=0.25 .and. a-b>-0.25)then
    write(*,*) "hello"//"work"
    end if
    write(*,*)'b=',floor(b)
    str='A.X1.53059.01.BHZ.D.2012.199.201545.SAC_sec5.5to4.8_spetral.txt_kernel'
    str=str(1:17)//'.dlnA.txt'
    write(*,*)str
end program main

subroutine change(a)
    implicit none
    integer::a(5)

    a=(/1,1,1,1,1/)
end subroutine change
