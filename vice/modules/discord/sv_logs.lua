local webhooks = {
    ['tp-to-player'] = 'https://discord.com/api/webhooks/1462204376239177871/whDGUUL6TjSt72U1svgPHvS9-rJnDRvfihEoOrFWeXMxt81yJSn7NcqVMaNPVqERDaP0',
    ['sell-chips'] = 'https://discord.com/api/webhooks/1462207578120654953/VntsgBe3TirSirsj0rxenasly9sM5yPLgKmssBABxSnQlBk80SZbzXjAYI0dkV_aQZAl',
    ['cpr'] = 'https://discord.com/api/webhooks/1462207676925739069/_0cYK1fyIGKg7bN2ZQBLP0T_ySAf0AzryibtgjwOtibAIXKVhfEEQOd0JVgcbbXLUgPo',
    ['purchase-chips'] = 'https://discord.com/api/webhooks/1462207822321156289/5Fq_FQSWVEeuQfDm7VbUh7tlXN-UKE5qd17cTLqHV4pvSaIHymTgnfmQpywg8aHkbUbZ',
    ['police-k9'] = 'https://.com/api/webhooks/1386279921214554162/SCeWZ7wd5sjgYcEjVOFpZCUZNIbThVccPGO1I8rSbkwy8avILoQxZZvxMFyV9FDhkL8W',
    ['general'] = 'https://.com/api/webhooks/1386280055654715464/CbVD21aF4gRMUiXCfpAbYhv9sp8xrbeopr22l2dUlHGNhs5pqIV0wraUX5ZIZXHTe8E3',
    ['seize-boot'] = 'https://.com/api/webhooks/1386280187020181525/-j1UMRuPwR1wDNA8TxlO-o_WUsfFMO-4afIptl-rQkJNIXUVTAY1M1aflqp-45TG0Fst',
    ['pd-panic'] = 'https://.com/api/webhooks/1386280253542109245/CvybJWqU_DRqaW2YZLPUVta-aJgJyd4Vn5bk6ezk-q45D8sPK4l-5KYpbBEk1nlRNkv-',
    ['screenshot'] = 'https://discord.com/api/webhooks/1462505082263437353/JynH1TWl7kbsGjw8pxf8r2Ygb_NiMaVOYoBdwvxbJMHgf5jwMDV4b4gDReI5_Ly42ai2',
    ['manage-balance'] = 'https://discord.com/api/webhooks/1483574262894694430/Xep4TnGvI_FVF5fmUW8FALa7zx7pJz9vTxrWSSZbZrRGC06LPcIKUojOTvzEfm2YTAjQ',
    ['coinflip-bet'] = 'https://.com/api/webhooks/1386280573131161620/8DiFR-TiiBTgajV_xsj0jqqe9zvvmzABhbpUIp_XlkNY0G9l_Zc1dBeo_pR-B3bEcIgj',
    ['gang'] = 'https://.com/api/webhooks/1386280627862638642/bIFvoZ1TO6SBqZ-hln4WrOggCW02H6kYco-ppsAiB7hBc0t98zTI1KjhCI-YCiwjPYRE',
    ['sell-vehicle'] = 'https://.com/api/webhooks/1386280687526481952/LSDEazHvAI7W8RQCr6PfKh8F9sgVDP_uLNK6yNR9CKmDMwlk0d5VXD_F_-VGu55Ne3j0',
    ['pd-clock'] = 'https://.com/api/webhooks/1386280752953425931/B_K7d_evVGKqEFzykA3bNaDTxpaW5DPoJO4cMMM-rKxVTobALTXOmQWf6aovLKWh-OF4',
    ['remove-warning'] = 'https://.com/api/webhooks/1386280855630123029/pmSdQwu4pyGxrQ_I44-XPXuAR_ODsIPHgSDEl5xCtuH9O2YBsGVNxrSPqP23Bs9-7ATk',
    ['slash-me'] = 'https://.com/api/webhooks/1386280998525734982/ZHOGzuijkejEpR4ggVIGK2EtTCiGTGruYvt4LU5tqAADKnrNPbeGLSEEEG6K86jySbji',
    ['leave'] = 'https://.com/api/webhooks/1386281077865451621/C01chElgI3NpDUWvvxPVg1OZ8u7pP3MPNkedM9LPmwIBlxHdJqlGoOK4mE5O8cEgM1Z8',
    ['housing-buy'] = 'https://.com/api/webhooks/1386281154054852738/UaKrJTvVxio9_kD86sHwNSgPCVpMf8P9MxNGrjHe9sHCXJoNRFJvpFWnLeCuaoTXwgKp',
    ['housing-rob'] = 'https://.com/api/webhooks/1386281215086170152/1s7q7gal7DfeJGMF-CCr9MACcGd4wA1oamjb6Qhg65RY4LeqbGhXYEQ1d4k9ivsvPyor',
    ['housing-rent'] = 'https://.com/api/webhooks/1386281315359260823/UmBC9sosyxB8-MNS19VB3yGZn6iwEc9v8gYC4XAA9mtAcECGcMJExtzNsXwGIOvG5BZ0',
    ['fine-player'] = 'https://.com/api/webhooks/1386281386347855932/-oXQXZT_Zl1rixvZbmmCHMjCW57Tyz8n4KvBOx6-vQiADv7UrxGiRrRclv88afgYAkus',
    ['lock-pick'] = 'https://.com/api/webhooks/1386281516065357965/vqsx7Qaucj1f4XAjaan0wl0Lxu5lUPKKnhroCybK5nVCe1eXRzqn0JCARn4DFWFOOjRz',
    ['staff'] = 'https://discord.com/api/webhooks/1462846200997740615/X4XQXARF4WGUmoujLg8j9MncwIcI7CQ6qMNtoTeXRk-NAICtfzWpZ3xljf5XS480YeIC',
    ['blackjack-bet'] = 'https://.com/api/webhooks/1386281696541802567/8MPw48f7S2ohBbxa_aag_MaOliPPjNKOn7IsfLd7zlfiUClFwxW9JmdiZhvbul3eTo8V',
    ['vehicle'] = 'https://.com/api/webhooks/1386281786291654777/PTu3jDfdK_43erPcCSSRTa6AF24k-mg4926_aKbgaU4a29N3ARoCJlP2yRotRdMpg0i4',
    ['announce'] = 'https://discord.com/api/webhooks/1483570066279628973/r47zWxwRrqLTkMw7xHBTZ9_t0IAGuq_uFYwEPusuX9PfEpmKF6QDl_U96cKVz6bfP9ei',
    ['give-cash'] = 'https://discord.com/api/webhooks/1389595289169428500/eKvhDlKAmQv6_YBdYmmKVoNR57izOzvqjJzb3SdAPdC4FP6xHlAXWseSH7IX0VuUwwEJ',
    ['tp-player-to-me'] = 'https://discord.com/api/webhooks/1483570970403799250/3IEF0pTJsmrorGXp5D9mESuIHXA8R1vgM-wo_MZEVC2Vg7Z0b4nxQZhgau1Ss6gHSEnD',
    ['search-player'] = 'https://.com/api/webhooks/1386282073664389130/iqUGrux2020Rzw8Trocnewiym_7V5ZJwVYN5FsMMiwe3g7sVQQo6mCXvJxqHEKZm-pmM',
    ['sell-to-nearest-player'] = 'https://.com/api/webhooks/1386282073664389130/iqUGrux2020Rzw8Trocnewiym_7V5ZJwVYN5FsMMiwe3g7sVQQo6mCXvJxqHEKZm-pmM',
    ['chat-logs'] = 'https://discord.com/api/webhooks/1483571312671719445/4AX_nFHHPGxWpkDkYJ9alp4HsAVibDXjV8LiZ3ajBWIYruYS0YPy5Be5scLNi1T_yO8B',
    ['Global-logs'] = 'https://discord.com/api/webhooks/1483571603156504738/rW1XDI2xc9akxtQGx2W94s0Jcexc-cUmIYF68adxytOF34BXUvQefLaOKDSD4lwv8bUu',
    ['server-bug'] = 'https://discord.com/api/webhooks/1462505471406637159/SFKsPhr3pFzp2-SdKg_L7gYjfaZe939IhPGYU3trpU1Z0-hhTgE3ysKDFHIzA2mTjTjw',
    ['client-bug'] = 'https://discord.com/api/webhooks/1462505325331480703/5LA-CscAD_LL_D7P1jfcKtpZf1pCz_CwmoDWlfFeJ5ewtF8zw-Ib6nsCrTDrasNstEkM',
    ['tp-back-from-admin-zone'] = 'https://discord.com/api/webhooks/1483572025187635331/4eT1QlRR0kFTGkZydXxnHqvi1VS_TzNhwKeRzOJT8ngi3g5WQHcuuMzZw9arV0xPQ0bW',
    ['kick'] = 'https://discord.com/api/webhooks/1462504299048472847/mSFr2c1Fizmqu5DXohR1KKoCCpKh3PzA41qOqgk5w7NxWNVZZiQlsZcId07Ghwf40xm4',
    ['kit-redeem'] = 'https://.com/api/webhooks/1386282662305595555/r1_dXRFFBgbmQ-jmhT5xecPxFVpEvKHdqIuzZt_g3yVGopJzmuaYbvA8_AtuCBgYEE',
    ['twitter'] = 'https://.com/api/webhooks/1386282709713817600/REkpU5fXX6GXAkO0fnlFQDbpH610HShYXvY03O0JbaOUSD1sSNsvH-K-Hob1veEI_f6N',
    ['jail-player'] = 'https://.com/api/webhooks/1386282789057462303/opb-wABaoz6uQn8jX7O8yHHGyvRjjE-vtN0T7djcEZgBJNW6dqLvl9moKn09LYWdpkTr',
    ['rent-vehicle'] = 'https://.com/api/webhooks/1386282868187070596/Y0Eye-udVxF5GCLFybxX-zpTzh8Rhhf42iio-Xwebdq0v4MadEAocjDpoRUJ_NCLWHK4',
    ['group'] = 'https://discord.com/api/webhooks/1483574513785376878/4ZJK_OJLjb9HRuAB-HFR6w9hxxsNyF9IkYdfyT0BoSLM3sPaeNOnSg5IzOmqpiXd-w-P',
    ['tp-to-legion'] = 'https://discord.com/api/webhooks/1483572246697214003/a1iVXS4Kujk2yLdEvr02jCJzUNsHG6YRVVwlmtUeF0_pPGVTX-SMSBItWaU42S2BIjCm',
    ['tp-to-paleto'] = 'https://discord.com/api/webhooks/1483572536125034497/MPQFe03lzkdLyOO4negZzK9-XiORfeyrtv-0qL0ptylN-7nHM2bWruP3NzYQve9kZ0Px',
    ['multiaccounting'] = 'https://.com/api/webhooks/1386283225977978900/phxffXCaJStl2_VBeFQMFwf9axSDeGWTDZbad3YMs6q9IiE5wj3Ga9oXoMvEh9y2v832',
    ['organ-tp'] = 'https://.com/api/webhooks/1386283304323387532/ImmJ_uvqmo2g3cI5teiR16f5UG-OQizOyN2yMFr2cwyPwOtMPUKKTa6UOJCBw4k1p-gh',
    ['feedback'] = 'https://discord.com/api/webhooks/1389595391238078564/OFh2JkuCZaVeExE3acn3F2YIKbn1-Px_YHU66l0IcVTCN8vDAY2KOM3ZY7kkfw42IHZP',
    ['housing-sell'] = 'https://.com/api/webhooks/1386283483705643150/0sKevg2oT97MJfFyIrrrwkSGg-4CtU_zZvuEAENn-yLBPN9Fg4WN773w4jxqH3gXuu0F',
    ['adminticket-logs'] = 'https://discord.com/api/webhooks/1483574738109337877/h91Vc-xKBmv2ijWdYGH0ma-rpFA0Mo4Gqi3j0CSOFFpcSPju-QgCydCU9uRry4lCNg_l',
    ['server-restart'] = 'https://discord.com/api/webhooks/1483574906330288272/GsG__P1RpDCFg6bhaxPH8S6DKavf7qICBh6tqGyIUU078zBEzkO98TDQlNdayKWCvKp-',
    ['anon'] = 'https://discord.com/api/webhooks/1483573861436882945/MKlpTZD-y3xl7MAbdy73WLv9eqfqblGSduL53ZzQQVgZIwBh81F4mb9gGHGckTEueffD',
    ['join-leave'] = 'https://discord.com/api/webhooks/1389594295891267694/jxzyXwA3xuIr4XvsF5NctdtSuRRR9OzISuNmeTs8-8FlDpcndKHpgHGYQtMMIihjt-eH',
    ['damage-logs'] = 'https://discord.com/api/webhooks/1483575158894497904/joeH1aE3yhOdJkFcCuIrT1GETGYq2eCkzwRnUfArLclPlXNhlWYRQwn5_U6WoeFWVH-c',
    ['weapon-logs'] = 'https://discord.com/api/webhooks/1483575566794883209/wXBW7MH-M12Yca3uR6jizH1Whm9ZldhhIFPy-WojMx8bUm8uKT6uBLAfHly0Xl6c889o',
    ['force-clock-off'] = 'https://.com/api/webhooks/1386284068806594630/PCZL-4qYW3Ucrxc2sL4w3MzwzSOovcLmS3R3oc6Ur0vS1lT6j73tZW_20YOLVoiOxDb4',
    ['impound'] = 'https://.com/api/webhooks/1386284181067141140/reoT55GFYXZLRUjqd2Jd7wzniJzqOnP3DTD5KnXdJHidQKkwuemjfCvD0_ko6RAxQFs5',
    ['ask-id'] = 'https://.com/api/webhooks/1386284269181341746/z2SyjYUyK0NPdk3cSGFkRaBbBCd3yxRe0KvaX7XZz37BgCc1xn2e79oEZ1z-bTEPStN9',
    ['revive'] = 'https://discord.com/api/webhooks/1462510020435509472/kgpRpNTZP4atsff7fXvwz3OJf-LpwMqhI9HWoJP0MHNoGGwtWYid6Wmi8chkUFWpo9Dz',
    ['media-cache'] = 'https://discord.com/api/webhooks/1463210462035312751/hCLkJN4TTbm-sp07AmnT73qOXXuxJ2daDhXS-PM7OSe9DF4HgkaGK_24L7nGiBw-ovuV',
    ['trigger-bot'] = 'https://discord.com/api/webhooks/1483568240595828976/fIERtY2LlXF13yEzY_2dRUO6MOsGo8aj-k8H0oxwhOcMl0eWiUtXYwpk_rPQM4KPBljA',
    ['unban'] = 'https://discord.com/api/webhooks/1462504600245633291/zlkslLe3rZtVCZHdGIfyT8daiX2XZfz6I_5ToCR-59p2_Lh9vl3d2wwMHkXzWP8TvrO6',
    ['purchases'] = 'https://.com/api/webhooks/1386284987619344435/iG_oag-fCgMxwzEQeeO1SmULycsZhIo8Fb-dnwxfFkir1icdtr4ItavHgZuV9oFkwX3B',
    ['add-car'] = 'https://discord.com/api/webhooks/1483573482213212393/aQHT07bMHiL-0psVUkcqhD0-eeBS2SNGL-qeF0LQ3OFBBEilMcVGMZF57IoTELHDW0W6',
    ['tutorial'] = 'https://.com/api/webhooks/1386285130334601246/BK5duXVcBndnfyOnRVhGRj3hvNrjonTSisjZOJkqkeor-t-hYjQqUSO2dhLGyLU4-dfF',
    ['ban'] = 'https://discord.com/api/webhooks/1462504692092375248/kGgor3OUeqEJY8CxgjTpcfMxjf_pNLgdwavociATcpWVu71co7r19grXpA4YGzYWQoZv',
    ['tp-to-admin-zone'] = 'https://.com/api/webhooks/1386285386241806396/n9XBtpaJr88GBqxNmWOWW37XTFHMicT6Qfx1HYVD25ryMdVceusEEWxsFOEeln0LNRQU',
    ['ban-evaders'] = 'https://.com/api/webhooks/1386285990083301478/C-WmgUazsX-EOQakQolBXiutUIBeUd8VpyYCHOowltyL7YnNWtNbkUSeLndVOJ06CtPW',
    ['spectate'] = 'https://.com/api/webhooks/1386286556779909150/HZ_ey-qpy7-WtxgCQ_XYvP_b7kHW7G4N68DLXEpEc03sMGK-_8sLlqn9zK1DQ3FL7WN8',
    ['video'] = 'https://discord.com/api/webhooks/1462504501922496658/P2L-VXbeK7F5yUxtbt8oDQNvfNA1uWJQvAJ0nXGCSNx5kxDJQv5vZmOhTPwTr3pD9t2Q',
    ['anticheat'] = 'https://discord.com/api/webhooks/1462505715964055798/3b8lUHhg34DGrTs8DCI1nYNwuJ9k1Wa-n1Qt1eGHMePi9rd9E_Ga0EWQLygFShLh5KDV',
    ['freeze'] = 'https://.com/api/webhooks/1386287198038392863/UeLRFx9PosTvKeIjQe538K-Cwx6P25VLSUQueGLSfzEC42HwNPrf8y_CK3MyKGgn7Vi-',
    ['filtered-message'] = 'https://.com/api/webhooks/1386287500837916722/3bV-GeMAIjvcrixSHnDPM4uyKTzcb_Zhi2yjtJD0Obw94MkFMnQPMAIe26zvHtH0-aPe',
    ['cleanup'] = 'https://.com/api/webhooks/1386288644108718151/ZzkMSZz36Kk-Kb8szeTMNUdHv2FWXFwXd28SdBxkq2Y_T2X9h7IuZI5G9usiyXkiZFJm',
    ['pd-armoury'] = 'https://.com/api/webhooks/1386288711209062510/uGGo04e53i9sA7sDeiYueSpFSX0P1xA6TT3Dcw26_8HQhOCS9Lshnv4KbUMqTceNM_z-',
    ['staff-mode'] = 'https://discord.com/api/webhooks/1483570614517370951/PGfUEJMUxFXdbIJV1ChnmbUkkMJstiEUJk6SEFE3s3hWHWdMK8DY6fQgNDbfuzfqStIc',
    ['unstuck-logs'] = 'https://.com/api/webhooks/1386289614691635271/8jN2SifO00B_cAmTMKPi2DUOJHFTgvDlizxX677vJExFjIvb0jSuRn6B9oP2vGhmhPTw',
    ['com-pot'] = 'https://.com/api/webhooks/1386290075247317002/puSHIRmteJ1jtgxbKunmRywABQzf6BTyXOLpVAqBfHiNMq8dNrHKjsHCN0WfAhrMLuUP',
    ['no-clip'] = 'https://.com/api/webhooks/1386290283322278068/KEDfUVkdgTFkYqWoNwR6AYQsqMiSCFczMTe4B_BpeDPENHzGp0jeSc34goDdeqHMC7sO',
    ['pd-afk'] = 'https://.com/api/webhooks/1386290520665358366/JBCkP6n4Xg-SmUboEcZXt3_yULjWcqOWM0N8EqGNXaBW6waUk3CMvMN2F5KqQNSUowiL',
    ['donation'] = 'https://.com/api/webhooks/1386291262121967616/VFOhSI2jnjBBYxWqD2mPUUEpEn4e-LiBNZi-UnLv1P0VPKxhDCwlKSUyUQ5BcjQgi8oS',
    ['slap'] = 'https://.com/api/webhooks/1386291341302038538/cNHPf4M38iEyJ6RfFCZaBY9d-eXcpv-cLo5Nz1K_4iqIpBBcs0AEnusonrVlccn0tC5R',
    ['crush-vehicle'] = 'https://.com/api/webhooks/1386291425817399409/ctNnWUrTAY5yTrTM4EAAhMgWTLqMpVkXfVcobSP94AySbv5KCB9oiRh7xUMDfjdUIt9C',
    ['killfeed-logs'] = 'https://discord.com/api/webhooks/1462251796180373723/hatMHxQuMcUyqp_gdkqfKkLD7hUEBYNjDWCFVziWGsOeOCCjfytZVcasrj1URCQRodwn',
    ['kills'] = 'https://discord.com/api/webhooks/1462251687312883714/DKxJ3Ewtb2y2FSVgZpjtFyKa7f8X5yWcvfJdeXe6IU2izWLAbMLOjmralvqHrLMiZzj5',
    ['purchase-highrollers'] = 'https://.com/api/webhooks/1386292633969754224/Gqw-1qxMVyEvIBGVurf7NIOdJThQQJ6joeh8C3M5PJXfYOP9-eR8tZAzeOilgkSoBMWE',
    ['warning'] = 'https://.com/api/webhooks/1386292936198586438/r2zzb5GuddqugwAU2nCX_C7qKPFqzHWmYVM8lwhNZ85-h1hESa9khlE_KTXgCTGY2J6u',
    ['car-report'] = 'https://.com/api/webhooks/1386293247235854428/sNivt95ehkma85noKGqKtRWKnxxgsXJdKyQOoA2upmolNHtTE7VEjrsTUf22ZF22XvFR',
    ['headshot'] = 'https://discord.com/api/webhooks/1462506197092667559/c2qt_8gnGrFEUvfYL7XBcrbLVUh86VRujijkrMXR6UArzQ0d4shY_uFatU62sR1LlmyS',
    ['errors'] = 'https://.com/api/webhooks/1386293842080174201/getwBbAVKcXWBvC-fWUuN70WiJ4tHkce5EdAPgowFdEt13Z7WObee3ayIhGiPGHbC_In',
    ['compensation-request'] = 'https://.com/api/webhooks/1386294446873907343/As8xdHhGUHysyG9ArSXm8-UiYslrgZOMFAjo-DCvOXNWrK5ebobXF_LLoapfxNucaUT2',
    ['car-dev'] = 'https://.com/api/webhooks/1386295792146452551/1EYaogHT3LQYp2Tay2WwNiCW3847WkDJmGPhodso6LwHgTwtrLJO7F90aujRwzuvOhlc',
    ['paycheck'] = 'https://.com/api/webhooks/1386296260088172635/H0fVE-BluGnXrFPmwc6Bq56HU1s2e-UEjBdw0m-dyTJeiQy-rkrejMBJ_fwA_eUKRlQP',
    ['hidden-state'] = 'https://.com/api/webhooks/1386296286499831868/1yNG3miiCOn_2ohytEpwIr7gAuuGD56_PwNsg4cWFIFRgZ0ithxJjC7ZQGmOiZP04RMt',
    ['discord-reverify'] = 'https://.com/api/webhooks/1386296559922319395/i2aT_OCGIIiPxPh-s8lGjqAFg06NKlLMFo6Ypxy_QBdxGHRmjocZ90MLouzN5oyrNssE',
    ['staff-dm'] = 'https://.com/api/webhooks/1386296866399846510/PvcB_dV_T2f40gwvBKZmX71hGMUH9cpQTkbIocD8fFChLERgAYP1P0JKyjXXnf6H4AUj',
    ['gang-info'] = 'https://.com/api/webhooks/1386297164115738735/z6JX3lv_h4DwoWsHtzHoFlN1sefnn8fNECRQ2mQF3dHU6CrHVo0mkck6eLO4saTrtN',
    ['spawn-vehicle'] = 'https://.com/api/webhooks/1386298754897940532/Brwpd_HaRlEpglsUezFThkP0ziCZIfJ-nOFXjbhhVWbtDymc4txDH3fC-mtpXKUiimr9',
    ['lootbag'] = 'https://.com/api/webhooks/1386298820153049108/yZ5vVinB1udSl7C98-iuTu9WRc0FoAsdoMN6YHRi1Iz00KVLM1hn1BW1JHTu-CaSlKma',
    ['new-users'] = 'https://.com/api/webhooks/1386298976076173372/P7Le-ouuloPpqjUqsTCU4koG2piZyThUqiMBIo66v-6E6e936gygbIfFrbSYpBwsKoL3',
    ['be-like-this'] = 'https://.com/api/webhooks/1386297767886061618/GP91Yz-kvcfWBEO6yBhKW0PFsjDQhR5XjqbqywNB02ih91yK7n9gc8KwI5XmIGQdEQBg',
    ['event-logs'] = 'https://discord.com/api/webhooks/1483575776908410942/fmP2yA7N8P9JJHOHo-yPBat-glbBuSwDs8CLSoigjKO6kShqG9A_jWXwHGqvEDHd95En',
    ['dont-be-like-this'] = 'https://.com/api/webhooks/1386297767886061618/GP91Yz-kvcfWBEO6yBhKW0PFsjDQhR5XjqbqywNB02ih91yK7n9gc8KwI5XmIGQdEQBg',
    ['spawn-weapon'] = 'https://.com/api/webhooks/1386297767886061618/GP91Yz-kvcfWBEO6yBhKW0PFsjDQhR5XjqbqywNB02ih91yK7n9gc8KwI5XmIGQdEQBg',
    ['checkdevices'] = '',
    ['noclip'] = 'https://discord.com/api/webhooks/1462505838970409073/Jjf4vEAgw4W_NxPjEbIbnm7v6z4lKl_Y5FV9T4hN03Vy2fOjCBwgcqDOIpIWnQtWGwev',
    ['wagers'] ='https://discord.com/api/webhooks/1483274076893089985/X3JSB-0Vs9r7NeMrZx215M01UtaBV16OTGolbCFHW__9-t1GjgVnfE9rPOEWQBIai8iy'
}

local webhookQueue = {}
Citizen.CreateThread(function()
    while true do
        if next(webhookQueue) then
            for k,v in pairs(webhookQueue) do
                Citizen.Wait(100)
                if webhooks[v.webhook] then
                    PerformHttpRequest(webhooks[v.webhook], function(err, text, headers) 
                    end, "POST", json.encode({username = "VICE Logs", avatar_url = 'https://imgur.com/a/T0wZYT5.png', embeds = {
                        {
                            ["color"] = 0x00328E,
                            ["title"] = v.name,
                            ["description"] = v.message,
                            ["image"] = {
                                ["url"] = v.image,
                            },
                            ["footer"] = {
                                ["text"] = "VICE - "..v.time,
                                ["icon_url"] = "",
                            }
                    }
                    }}), { ["Content-Type"] = "application/json" })
                end
                webhookQueue[k] = nil
            end
        end
        Citizen.Wait(0)
    end
end)
local webhookID = 1
function VICE.sendDCLog(webhook, name, message, image)
    webhookID = webhookID + 1
    webhookQueue[webhookID] = {webhook = webhook, name = name, message = message, image = image or "", time = os.date("%c")}
    local file, err = io.open("C:\\FXServer\\resources\\[VICE]\\[VICE]\\vice\\logs\\" .. webhook .. ".txt", "a")
    if file then
        file:write("Webhook: " .. webhook .. ", Name: " .. name .. ", Message: " .. message .. ", Image: " .. (image or "") .. ", Time: " .. os.date("%c") .. "\n")
        file:close()
    else
       -- print("Failed to open file: " .. err)
    end
end

function VICE.getWebhook(webhook)
    if webhooks[webhook] then
        return webhooks[webhook]
    end
end

RegisterServerEvent("VICE:sendWebhookClient")
AddEventHandler("VICE:sendWebhookClient", function(webhook, name, message)
    VICE.sendDCLog(webhook, name, message)
end)

RegisterServerEvent("VICE:logVehicleSpawn")
AddEventHandler("VICE:logVehicleSpawn", function(spawncode, thingy)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        VICE.sendDCLog("vehicle", "VICE Spawn ".. thingy .." Logs", "> Vehicle Spawncode: " .. spawncode .. " \n> Player Name: " .. VICE.getPlayerName(user_id) .. " \n> Players TempID: " .. source .. " \n> Players PermID: " .. user_id)
    end
end)