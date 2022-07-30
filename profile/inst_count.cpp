#include <fmt/core.h>
#include <map>
#include <string>
#include <fstream>
#include <vector>

using std::string;

class decoder
{
public:
    decoder()
    {
        insert({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0},"rdtimel.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1},"rdtimeh.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},"add.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0},"sub.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0},"stl");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1},"sltu");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0},"nor");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,1},"and");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0},"or");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1},"xor");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0},"sll.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,1},"srl.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0},"sra.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0},"mul.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,1},"mulh.w");
        insert({0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,0},"mulh.wu");
        insert({0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0},"div.w");
        insert({0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1},"mod.w");
        insert({0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0},"div.wu");
        insert({0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1},"mod.wu");
        insert({0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0},"break");
        insert({0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1,0},"syscall");
        insert({0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1},"slli.w");
        insert({0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1},"srli.w");
        insert({0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,1},"srai.w");
        insert({0,0,0,0,0,0,1,0,0,0},"slti");
        insert({0,0,0,0,0,0,1,0,0,1},"sltui");
        insert({0,0,0,0,0,0,1,0,1,0},"addi.w");
        insert({0,0,0,0,0,0,1,1,0,1},"andi");
        insert({0,0,0,0,0,0,1,1,1,0},"ori");
        insert({0,0,0,0,0,0,1,1,1,1},"xori");
        insert({0,0,0,0,0,1,0,0},"csr");
        insert({0,0,0,0,0,1,1,0,0,0},"cacop");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0,1,0,1,0},"tlbsrch");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0,1,0,1,1},"tlbrd");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0,1,1,0,0},"tlbwr");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0,1,1,0,1},"tlbfill");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0,1,1,1,0},"ertn");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,1},"idle");
        insert({0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,1,1},"invtlb");
        insert({0,0,0,1,0,1,0},"lu12i.w");
        insert({0,0,0,1,1,1,0},"pcaddu12i");
        insert({0,0,1,0,0,0,0},"ll.w");
        insert({0,0,1,0,0,0,1},"sc.w");
        insert({0,0,1,0,1,0,0,0,0,0},"ld.b");
        insert({0,0,1,0,1,0,0,0,0,1},"ld.h");
        insert({0,0,1,0,1,0,0,0,1,0},"ld.w");
        insert({0,0,1,0,1,0,0,1,0,0},"st.b");
        insert({0,0,1,0,1,0,0,1,0,1},"st.h");
        insert({0,0,1,0,1,0,0,1,1,0},"st.w");
        insert({0,0,1,0,1,0,1,0,0,0},"ld.bu");
        insert({0,0,1,0,1,0,1,0,0,1},"ld.hu");
        insert({0,0,1,0,1,0,1,0,1,1},"preld");
        insert({0,0,1,1,1,0,0,0,0,1,1,1,0,0,1,0,0},"dbar");
        insert({0,0,1,1,1,0,0,0,0,1,1,1,0,0,1,0,1},"ibar");
        insert({0,1,0,0,1,1},"jirl");
        insert({0,1,0,1,0,0},"b");
        insert({0,1,0,1,1,0},"beq");
        insert({0,1,0,1,0,1},"bl");
        insert({0,1,0,1,1,1},"bne");
        insert({0,1,1,0,0,0},"blt");
        insert({0,1,1,0,0,1},"bge");
        insert({0,1,1,0,1,0},"bltu");
        insert({0,1,1,0,1,1},"bgeu");
    }
    std::string decode(unsigned inst)
    {
        unsigned p,i;
        for(i = 1<<31,p=0;p!=-1&&tree[p].name==0;p=tree[p].next[(inst & i)!=0],i>>=1);
        try
        {
            return namelist.at(tree.at(p).name-1);
        }
        catch(std::out_of_range)
        {
            return "invalid";
        }
    }
private:
    struct node
    {
        bool data;
        int next[2];
        int name;
    };
    std::vector<node> tree{node{false,-1,-1,0}};
    std::vector<string> namelist;

    void insert(std::vector<bool> code,std::string name)
    {
        namelist.push_back(name);
        int p=0;
        for(auto i: code)
        {
            if(tree[p].next[0]==-1) {
                tree[p].next[0] = tree.size();
                tree[p].next[1] = tree.size()+1;
                tree.push_back({false,-1,-1,0});
                tree.push_back({false,-1,-1,0});
            }
            p = tree[p].next[i];
        }
        tree[p].name = namelist.size();
    }
};

int main(int argc,char **argv)
{
    class decoder decoder;
    if(argc!=2)
    {
        fmt::print(stderr,"Usage: {} <trace>\n",argv[0]);
        return 1;
    }
    std::ifstream trace_in(argv[1]);
    trace_in>>std::hex;
    std::map<int,int> pc2cnt;
    std::map<string,int> type2cnt;
    while(true)
    {
        unsigned pc,inst,exp;
        trace_in>>pc>>inst>>exp;
        if(!trace_in)break;
        ++pc2cnt[pc];
        ++type2cnt[decoder.decode(inst)];
    }
    fmt::print("Type -> cnt\n");
    std::map<int,string> cnt2type;
    for(auto [type,cnt]: type2cnt)
    {
        cnt2type.insert({cnt,type});
    }
    for(auto it = cnt2type.rbegin();it!=cnt2type.rend();++it)
    {
        auto [cnt,type] = *it;
        fmt::print("{:15}: {:6}\n",type,cnt);
    }
    fmt::print("\nPC -> cnt\n");
    for(auto [pc,cnt]: pc2cnt)
    {
        fmt::print("{:08x}: {:6}\n",pc,cnt);
    }
    return 0;
}
