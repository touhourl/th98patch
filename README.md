# The patch of games for RL
If you are not a dev, I sincerely don't recommend you to build it from source. You need to read the things under, if you don't read, any issues are possible. You have been warned. But if you did this, and found an issue, please create a issue.
## Setup
```bash
sudo apt install bsdiff
./patch.sh <dir>
```
And then you need to manually modify the GAME.BAT: Change all op to debloat.
And then, do:

```bash
echo "[dosbox]
machine=pc9821
memsize=8

[cpu]
core=normal
cputype=386
cycles=12000" > ./default.conf
```

```bash
echo "total_live=3
total_bomb=3
skip_to=6
skip_to_boss_phase=9
end_phase=0
char=2
rank=0
power=128" > ./KAIKII.CFG
```
One creates the default.conf for dosbox-x and one creates KAIKII.CFG.
Then you need to test launch it:

```bash
dosbox-x . -conf ./default.conf
```
Make sure that you compile dosbox-x from source!

# R.I.P ReC98
As [July 15, 2026](https://github.com/nmlgc/rec98.nmlgc.net/commit/eb4c9ead083f267eace73e687d364e2638e869f2), the ReC98 project sunsets. I am sad. I hope I or someone else can continue that project. It has really helped me so much in thrl project and this one. So, what will the future be? Well, [th06](https://github.com/GensokyoClub/th06) is decompiled and [th08](https://github.com/GensokyoClub/th08) is WIP. Or maybe thrl will just be all about Touhou fan games then. Touhou fans have been incredibly generous in the years. Thanks to [taisei-project](https://github.com/taisei-project/taisei) licensing all taisei source code under MIT/CC-BY-4.0, everything about this is legal, thus making taisei an objectively much more sustainable development by me.

## TH04 diff does:
1. Load the config GENSOO.CFG;
2. The config contains things like
    total_live=4    ; total lives (config lives)
    total_bomb=2    ; bombs (also config bombs)
    skip_to=2       ; skip to stage 2
    skip_to_boss_phase=0  ; start from stage 2 begin
    end_phase=0     ; end until boss is defeated
    char=1          ; character; shot type = 1 if char = 1 or 3 else 0.
    power=128
    rank=1
    ; if the skip to boss phase is 1, 2, or 3 or more then it indicates the boss's phase and the pattern (spell card alike)
3. The custom loader load the config, launch the main.exe.

## TH05 diff does:
1. Load the config KAIKII.CFG;
2. The config contains things like
    total_live=4    ; total lives (config lives)
    total_bomb=2    ; bombs (also config bombs)
    skip_to=2       ; skip to stage 2
    skip_to_boss_phase=0  ; start from stage 2 begin
    end_phase=0     ; end until boss is defeated
    char=1          ; character
    power=128
    rank=1
    ; if the skip to boss phase is 1, 2, or 3 or more then it indicates the boss's phase and the pattern
3. The custom loader load the config, launch the main.exe.

## Overall changes for all games:
1. Changed config names to ASCII, so to run under linux and called. This requires renaming .DATs.
2. Input control issue, cannot press shift key via memory reader
3. Custom loader
4. Disable dialogs
5. Stage changing is removed
6. Memory reading the resident, the last variable, if the stage success.

## How to apply the changes?
Clone the ReC98 repo, switch to anniversary branch and git apply.

## FAQs:
Q: Why build this project?

A: For the reinforcement learning of touhou games

Q: HUMAConfig

A: I know that. The resident structure.

Q: むやみにＳＴＯＰキー押したりしない方がいいと思うの。（ゲーム中はね）（ＳＴＯＰキーで戻れるよ、ねっ）

A: F this STOP error. The inner debugger of touhou (pc-98) (games).

Q: How did you made it to skip?

A: ZUN Bloat in resident structure. While the young ZUN creates many bloats in resident, we just take it as the shared memory of MAIN.EXE and play it. We modified source of MAIN.EXE and we created a custom loader. Note that, debloatm and debloat.exe as for th05.

Q: How long you made it?

A: IDK but more than 3 months worked on it.
