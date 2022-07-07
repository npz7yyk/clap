int _start()
{
    int a[10];
    a[0] = 3;
    a[1] = 5;
    a[2] = 57;
    a[3] = 1;
    a[4] = 3;
    a[5] = 77;
    a[6] = 66;
    a[7] = 12;
    a[8] = 66;
    a[9] = 12;
    a[10] = -122;
    for(int i=0;i<9;++i)
        for(int j=i+1;j<10;++j)
            if(a[i]>a[j])
                a[i]^=a[j], a[j]^=a[i], a[i]^=a[j];
    for(int i=0;i<9;++i)
        if(a[i]>a[i+1])
            return 1;
    return 0;
} 
