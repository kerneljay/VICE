"use strict";

function _defineProperty(e, t, i) {
    return t in e ? Object.defineProperty(e, t, {
        value: i,
        enumerable: !0,
        configurable: !0,
        writable: !0
    }) : e[t] = i, e
}
const isNotNullNorUndefined = function(e) {
    return null != e
};
class KillFeed extends React.Component {
    constructor(...e) {
        super(...e), _defineProperty(this, "state", {
            active: !0,
            kills: []
        }), _defineProperty(this, "addKill", e => {
            let t = {
                victim: e.victim,
                killer: e.killer,
                weapon: e.weapon,
                suicide: e.suicide,
                victimGroup: e.victimGroup,
                killerGroup: e.killerGroup,
                range: e.range,
                uuid: e.uuid,
                type: e.category,
                isHeadshot: e.isHeadshot,
                rollKill: e.rollKill
            };
            if (this.setState({
                    kills: [...this.state.kills, t]
                }), this.state.kills.length > 6) {
                setTimeout(() => {
                    this.setState({
                        kills: this.state.kills.filter(e => e.uuid != this.state.kills[0].uuid)
                    })
                }, 1e3)
            } else {
                0 != this.state.kills.length && setTimeout(() => {
                    setTimeout(() => {
                        this.setState({
                            kills: this.state.kills.filter(e => e.uuid != this.state.kills[0].uuid)
                        })
                    }, 1e3)
                }, 1e4)
            }
        }), _defineProperty(this, "killFeedEnable", () => {
            this.setState({
                active: true
            })
        }), _defineProperty(this, "killFeedDisable", () => {
            this.setState({
                active: false
            })
        })
    }
    componentDidMount() {
        window.addEventListener("message", e => {
            let t = e.data;
            this[t.type] && this[t.type](t)
        })
    }
    render() {
        const e = this.state.active && this.state.kills.length > 0 ? this.state.kills.map((e, t) => {
            const headshotImg = e.isHeadshot ? React.createElement("img", {
                src: "killfeed/img/headshot.png",
                className: "headshot"
            }) : null;
            const rollBadge = e.rollKill ? React.createElement("img", {
                src: "killfeed/img/roll.png",
                className: "roll-icon",
                title: "Killed while combat rolling"
            }) : null;

            return e.suicide ? React.createElement("div", {
                className: "killFeedKill " + e.type,
                key: t,
                id: e.uuid
            }, React.createElement("p", {
                className: "kill",
                key: t
            }, React.createElement("img", {
                src: "killfeed/img/" + e.weapon + ".png",
                className: "weapon " + e.weapon
            }), headshotImg, React.createElement("span", {
                className: "victim " + e.victimGroup
            }, e.victim))) : React.createElement("div", {
                className: "killFeedKill " + e.type,
                key: t,
                id: e.uuid
            }, React.createElement("p", {
                className: "kill",
                key: t
            }, React.createElement("span", {
                className: "killer " + e.killerGroup
            }, e.killer), React.createElement("img", {
                src: "killfeed/img/" + e.weapon + ".png",
                className: "weapon " + e.weapon
            }), rollBadge, headshotImg, React.createElement("span", {
                className: "victim " + e.victimGroup
            }, e.victim), React.createElement("span", {
                className: "range"
            }, "(" + e.range + "m)")));
        }) : React.createElement("div", null);
        return React.createElement("div", null, React.createElement("div", {
            className: "killfeed"
        }, e));
    }
}
ReactDOM.render(React.createElement(KillFeed, null), document.getElementById("killfeed"));
